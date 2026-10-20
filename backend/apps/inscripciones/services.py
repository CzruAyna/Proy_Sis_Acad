from django.apps import apps
from django.db import transaction
from rest_framework.exceptions import ValidationError

from apps.oferta.models import Paralelo
from apps.usuarios.models import Usuario

from .models import Inscripcion


@transaction.atomic
def inscribir_en_paralelo(estudiante, paralelo_id):
    if estudiante.rol != Usuario.Rol.ESTUDIANTE:
        raise ValidationError("Solo los estudiantes pueden inscribirse.")

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

    inscripcion_existente = Inscripcion.objects.filter(
        estudiante=estudiante,
        paralelo__materia_id=referencia["materia_id"],
        paralelo__periodo_id=referencia["periodo_id"],
        estado=Inscripcion.Estado.CURSANDO,
    ).exists()
    if inscripcion_existente:
        raise ValidationError("Ya tienes una inscripción activa en esta materia y periodo.")

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
