from decimal import Decimal

from django.core.exceptions import ObjectDoesNotExist
from django.db import transaction
from django.utils import timezone
from rest_framework.exceptions import ValidationError

from apps.inscripciones.models import Inscripcion
from apps.oferta.models import Paralelo
from apps.usuarios.models import Usuario

from .models import Acta, CorreccionNota, Nota

NOTA_APROBACION = Decimal("51.00")


def _bloquear_acta(acta_id):
    referencia = Acta.objects.filter(pk=acta_id).values("paralelo_id").first()
    if referencia is None:
        raise ValidationError("El acta solicitada no existe.")
    Paralelo.objects.select_for_update().get(pk=referencia["paralelo_id"])
    return Acta.objects.select_for_update().select_related("paralelo").get(pk=acta_id)


@transaction.atomic
def guardar_notas(acta_id, actor, datos):
    acta = _bloquear_acta(acta_id)
    if acta.cerrada:
        raise ValidationError("El acta está cerrada y no admite cambios.")

    vigentes = {
        inscripcion.pk: inscripcion
        for inscripcion in Inscripcion.objects.select_for_update().filter(
            paralelo=acta.paralelo, estado=Inscripcion.Estado.CURSANDO
        )
    }
    vistos = set()
    guardadas = []
    for dato in datos:
        inscripcion_id = dato["inscripcion_id"]
        if inscripcion_id in vistos:
            raise ValidationError("Una inscripción aparece más de una vez en la solicitud.")
        vistos.add(inscripcion_id)
        inscripcion = vigentes.get(inscripcion_id)
        if inscripcion is None:
            raise ValidationError(
                {"inscripcion_id": f"La inscripción {inscripcion_id} no está cursando este paralelo."}
            )
        try:
            nota = Nota.objects.select_for_update().get(inscripcion=inscripcion)
        except ObjectDoesNotExist:
            nota = Nota(acta=acta, inscripcion=inscripcion, puntaje=dato["puntaje"])
        else:
            nota.puntaje = dato["puntaje"]
        nota.save()
        guardadas.append(nota)
    return guardadas


@transaction.atomic
def cerrar_acta(acta_id, actor):
    acta = _bloquear_acta(acta_id)
    if acta.cerrada:
        raise ValidationError("El acta ya está cerrada.")

    inscripciones = list(
        Inscripcion.objects.select_for_update().filter(
            paralelo=acta.paralelo, estado=Inscripcion.Estado.CURSANDO
        )
    )
    notas = {
        nota.inscripcion_id: nota
        for nota in Nota.objects.select_for_update().filter(
            acta=acta, inscripcion_id__in=[i.pk for i in inscripciones]
        )
    }
    faltantes = [i.pk for i in inscripciones if i.pk not in notas]
    if faltantes:
        raise ValidationError(
            {"notas": "Todas las inscripciones cursando deben tener una nota antes del cierre."}
        )

    ahora = timezone.now()
    for inscripcion in inscripciones:
        inscripcion.estado = (
            Inscripcion.Estado.APROBADA
            if notas[inscripcion.pk].puntaje >= NOTA_APROBACION
            else Inscripcion.Estado.REPROBADA
        )
        inscripcion.actualizado_en = ahora
    if inscripciones:
        Inscripcion.objects.bulk_update(inscripciones, ("estado", "actualizado_en"))

    acta.cerrada = True
    acta.cerrada_en = ahora
    acta.cerrada_por = actor
    acta._cierre_autorizado = True
    acta.save()
    return acta


@transaction.atomic
def corregir_nota(acta_id, actor, nota_id, puntaje, motivo, referencia_tramite):
    if not es_administrador_academico(actor):
        raise ValidationError("Solo Dirección o Administración pueden corregir notas.")
    acta = _bloquear_acta(acta_id)
    if not acta.cerrada:
        raise ValidationError("Las correcciones formales aplican solo a actas cerradas.")
    try:
        nota = Nota.objects.select_for_update().select_related("inscripcion").get(
            pk=nota_id, acta=acta
        )
    except Nota.DoesNotExist as exc:
        raise ValidationError({"nota_id": "La nota no pertenece a esta acta."}) from exc

    correccion = CorreccionNota.objects.create(
        nota=nota,
        puntaje_anterior=nota.puntaje,
        puntaje_nuevo=puntaje,
        motivo=motivo,
        referencia_tramite=referencia_tramite,
        corregida_por=actor,
    )
    nota.puntaje = puntaje
    nota._correccion_autorizada = True
    nota.save()

    inscripcion = nota.inscripcion
    inscripcion.estado = (
        Inscripcion.Estado.APROBADA
        if puntaje >= NOTA_APROBACION
        else Inscripcion.Estado.REPROBADA
    )
    inscripcion.actualizado_en = timezone.now()
    inscripcion.save(update_fields=("estado", "actualizado_en"))
    return correccion


def es_administrador_academico(usuario):
    return usuario.is_authenticated and (
        usuario.is_superuser
        or usuario.rol in (Usuario.Rol.DIRECTOR, Usuario.Rol.ADMIN)
    )
