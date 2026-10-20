from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from apps.inscripciones.models import Inscripcion
from apps.oferta.models import Paralelo


class Acta(models.Model):
    paralelo = models.OneToOneField(
        Paralelo, on_delete=models.PROTECT, related_name="acta"
    )
    cerrada = models.BooleanField(default=False)
    creada_en = models.DateTimeField(auto_now_add=True)
    cerrada_en = models.DateTimeField(null=True, blank=True)
    cerrada_por = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="actas_cerradas",
        null=True,
        blank=True,
    )

    class Meta:
        ordering = ("-creada_en",)
        verbose_name = "acta de notas"
        verbose_name_plural = "actas de notas"

    def clean(self):
        if self.cerrada and (not self.cerrada_en or not self.cerrada_por_id):
            raise ValidationError("El cierre requiere fecha y usuario responsable.")
        if not self.cerrada and (self.cerrada_en or self.cerrada_por_id):
            raise ValidationError("Un acta abierta no puede registrar datos de cierre.")

    def save(self, *args, **kwargs):
        self.full_clean()
        if self.pk:
            anterior = Acta.objects.get(pk=self.pk)
            if anterior.cerrada:
                if not self.cerrada or (
                    self.paralelo_id != anterior.paralelo_id
                    or self.cerrada_en != anterior.cerrada_en
                    or self.cerrada_por_id != anterior.cerrada_por_id
                ):
                    raise ValidationError("Un acta cerrada es inmutable.")
            elif self.cerrada and not getattr(self, "_cierre_autorizado", False):
                raise ValidationError("El cierre debe realizarse mediante el flujo autorizado.")
        elif self.cerrada:
            raise ValidationError("El acta debe crearse abierta y cerrarse desde el flujo autorizado.")
        super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        if self.cerrada:
            raise ValidationError("No se puede eliminar un acta cerrada.")
        return super().delete(*args, **kwargs)

    def __str__(self):
        return f"Acta · {self.paralelo} · {'Cerrada' if self.cerrada else 'Abierta'}"


class Nota(models.Model):
    acta = models.ForeignKey(Acta, on_delete=models.PROTECT, related_name="notas")
    inscripcion = models.OneToOneField(
        Inscripcion, on_delete=models.PROTECT, related_name="nota"
    )
    puntaje = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        validators=(MinValueValidator(0), MaxValueValidator(100)),
    )
    actualizada_en = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("inscripcion__estudiante__last_name", "inscripcion__estudiante__first_name")
        verbose_name = "nota"
        verbose_name_plural = "notas"

    def clean(self):
        if self.acta_id and self.inscripcion_id:
            if self.acta.paralelo_id != self.inscripcion.paralelo_id:
                raise ValidationError({"inscripcion": "La inscripción no pertenece a este paralelo."})
            if self.acta.cerrada and not getattr(self, "_correccion_autorizada", False):
                raise ValidationError("No se puede modificar una nota de un acta cerrada.")

    def save(self, *args, **kwargs):
        self.full_clean()
        if self.pk:
            anterior = Nota.objects.select_related("acta").get(pk=self.pk)
            if anterior.acta.cerrada:
                permitida = getattr(self, "_correccion_autorizada", False)
                if not permitida or (
                    self.acta_id != anterior.acta_id
                    or self.inscripcion_id != anterior.inscripcion_id
                ):
                    raise ValidationError("Una nota de acta cerrada es inmutable.")
        elif self.acta.cerrada:
            raise ValidationError("No se puede agregar una nota a un acta cerrada.")
        super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        if self.acta.cerrada:
            raise ValidationError("No se puede eliminar una nota de un acta cerrada.")
        return super().delete(*args, **kwargs)

    def __str__(self):
        return f"{self.inscripcion.estudiante} · {self.puntaje}"


class CorreccionNota(models.Model):
    nota = models.ForeignKey(Nota, on_delete=models.PROTECT, related_name="correcciones")
    puntaje_anterior = models.DecimalField(max_digits=5, decimal_places=2)
    puntaje_nuevo = models.DecimalField(max_digits=5, decimal_places=2)
    motivo = models.TextField()
    referencia_tramite = models.CharField(max_length=80)
    corregida_por = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="correcciones_notas_realizadas",
    )
    creada_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("-creada_en",)
        verbose_name = "corrección de nota"
        verbose_name_plural = "correcciones de notas"

    def save(self, *args, **kwargs):
        if self.pk:
            raise ValidationError("La auditoría de corrección es inmutable.")
        self.full_clean()
        return super().save(*args, **kwargs)

    def delete(self, *args, **kwargs):
        raise ValidationError("La auditoría de corrección no se puede eliminar.")

    def __str__(self):
        return f"Corrección {self.nota_id} · {self.referencia_tramite}"
