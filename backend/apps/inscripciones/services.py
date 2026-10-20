from django.apps import apps
from django.db import transaction
from django.db.models import Q
from rest_framework.exceptions import ValidationError

from apps.academico.models import PeriodoAcademico, Prerrequisito
from apps.notas.models import Nota
from apps.oferta.models import Paralelo
from apps.usuarios.models import Usuario

from .models import Inscripcion


def promedio_ordinario_anterior(estudiante, periodo_actual):
    anterior = (
        PeriodoAcademico.objects.filter(tipo__in=("S1", "S2", "ANUAL"))
        .filter(
            Q(anio__lt=periodo_actual.anio)
            | Q(anio=periodo_actual.anio, orden__lt=periodo_actual.orden)
        )
        .order_by("-anio", "-orden")
        .first()
    )
    if anterior is None:
        return None

    registros = Nota.objects.filter(
        acta__cerrada=True,
        inscripcion__estudiante=estudiante,
        acta__paralelo__periodo=anterior,
    ).values_list("puntaje", "inscripcion__paralelo__materia__creditos")
    total_creditos = sum((creditos for _, creditos in registros), start=0)
    if not total_creditos:
        return None
    return sum((puntaje * creditos for puntaje, creditos in registros), start=0) / total_creditos


def evaluar_inscripcion(estudiante, paralelo):
    motivos = []
    materia = paralelo.materia
    periodo = paralelo.periodo

    if Inscripcion.objects.filter(
        estudiante=estudiante,
        paralelo__materia=materia,
        paralelo__periodo=periodo,
        estado=Inscripcion.Estado.CURSANDO,
    ).exists():
        motivos.append("Ya tienes una inscripción activa en esta materia y periodo.")

    requisitos = Prerrequisito.objects.filter(materia=materia).select_related("requisito")
    for relacion in requisitos:
        aprobado = Inscripcion.objects.filter(
            estudiante=estudiante,
            paralelo__materia=relacion.requisito,
            estado=Inscripcion.Estado.APROBADA,
        ).exists()
        cursando_simultaneamente = relacion.es_corequisito and Inscripcion.objects.filter(
            estudiante=estudiante,
            paralelo__materia=relacion.requisito,
            paralelo__periodo=periodo,
            estado=Inscripcion.Estado.CURSANDO,
        ).exists()
        if not aprobado and not cursando_simultaneamente:
            if relacion.es_corequisito:
                motivos.append(
                    f"El corequisito {relacion.requisito.codigo} debe estar aprobado o cursarse en el mismo periodo."
                )
            else:
                motivos.append(
                    f"Falta aprobar el prerrequisito {relacion.requisito.codigo}."
                )

    carga_actual = Inscripcion.objects.filter(
        estudiante=estudiante,
        paralelo__periodo=periodo,
        estado=Inscripcion.Estado.CURSANDO,
    ).count()
    promedio = promedio_ordinario_anterior(estudiante, periodo)
    limite = 7 if promedio is not None and promedio >= 65 else 6
    if carga_actual >= limite:
        if limite == 7:
            motivos.append("Ya alcanzaste el máximo autorizado de siete materias para este periodo.")
        elif promedio is None:
            motivos.append("El límite es de seis materias; todavía no hay un promedio ordinario anterior para habilitar la séptima.")
        else:
            motivos.append(f"El límite es de seis materias y tu promedio ordinario anterior es {promedio:.2f}; se requieren 65 para la séptima.")

    return {
        "habilitada": not motivos,
        "motivos": motivos,
        "carga_actual": carga_actual,
        "limite_materias": limite,
        "promedio_ordinario_anterior": (
            round(float(promedio), 2) if promedio is not None else None
        ),
    }


@transaction.atomic
def inscribir_en_paralelo(estudiante, paralelo_id):
    if estudiante.rol != Usuario.Rol.ESTUDIANTE:
        raise ValidationError("Solo los estudiantes pueden inscribirse.")

    estudiante = Usuario.objects.select_for_update().get(pk=estudiante.pk)

    referencia = (
        Paralelo.objects.filter(pk=paralelo_id, abierto=True)
        .values("materia_id", "periodo_id")
        .first()
    )
    if referencia is None:
        raise ValidationError({"paralelo_id": "El paralelo no existe o no está abierto."})

    paralelos = list(
        Paralelo.objects.select_for_update()
        .filter(
            materia_id=referencia["materia_id"],
            periodo_id=referencia["periodo_id"],
            abierto=True,
        )
        .order_by("identificador", "pk")
    )
    seleccionado = next((p for p in paralelos if p.pk == int(paralelo_id)), None)
    if seleccionado is None:
        raise ValidationError({"paralelo_id": "El paralelo ya no está abierto."})

    elegibilidad = evaluar_inscripcion(estudiante, seleccionado)
    if not elegibilidad["habilitada"]:
        raise ValidationError({"inscripcion": elegibilidad["motivos"]})

    posicion = paralelos.index(seleccionado)
    Acta = apps.get_model("notas", "Acta")
    for paralelo in paralelos[posicion:]:
        if Acta.objects.filter(paralelo=paralelo, cerrada=True).exists():
            continue
        ocupados = Inscripcion.objects.filter(
            paralelo=paralelo, estado=Inscripcion.Estado.CURSANDO
        ).count()
        if ocupados < paralelo.cupo_maximo:
            return Inscripcion.objects.create(
                estudiante=estudiante,
                paralelo=paralelo,
                estado=Inscripcion.Estado.CURSANDO,
                origen=Inscripcion.Origen.ORDINARIA,
            )

    raise ValidationError("No hay cupos disponibles en este ni en los siguientes paralelos.")


@transaction.atomic
def retirar_inscripcion(inscripcion_id, estudiante):
    inscripcion = (
        Inscripcion.objects.select_for_update()
        .select_related("paralelo")
        .filter(pk=inscripcion_id, estudiante=estudiante)
        .first()
    )
    if inscripcion is None:
        raise ValidationError("No se encontró una inscripción propia con ese identificador.")
    if inscripcion.estado != Inscripcion.Estado.CURSANDO:
        raise ValidationError("Solo se puede retirar una inscripción que esté cursándose.")
    inscripcion.estado = Inscripcion.Estado.RETIRADA
    inscripcion.save(update_fields=("estado", "actualizado_en"))
    return inscripcion
