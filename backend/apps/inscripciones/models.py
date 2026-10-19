from django.conf import settings
from django.core.exceptions import ValidationError
from django.db import models

from apps.oferta.models import Paralelo


class Inscripcion(models.Model):
    class Estado(models.TextChoices):
        CURSANDO = "CURSANDO", "Cursando"
        APROBADA = "APROBADA", "Aprobada"
        REPROBADA = "REPROBADA", "Reprobada"
        RETIRADA = "RETIRADA", "Retirada"

    class Origen(models.TextChoices):
        ORDINARIA = "ORDINARIA", "Ordinaria"
        VERANO = "VERANO", "Verano"
        INVIERNO = "INVIERNO", "Invierno"
        MESA = "MESA", "Mesa"
        PERMISO_ESPECIAL = "PERMISO_ESPECIAL", "Permiso especial"
        AUTO_7MA = "AUTO_7MA", "Séptima materia"

    estudiante = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="inscripciones_academicas",
    )
    paralelo = models.ForeignKey(
        Paralelo, on_delete=models.PROTECT, related_name="inscripciones"
    )
    estado = models.CharField(
        max_length=10, choices=Estado.choices, default=Estado.CURSANDO
    )
    origen = models.CharField(
        max_length=20, choices=Origen.choices, default=Origen.ORDINARIA
    )
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-creado_en",)
        constraints = [
            models.UniqueConstraint(
                fields=("estudiante", "paralelo"), name="insc_estudiante_paralelo_uniq"
            )
        ]
        indexes = [
            models.Index(fields=("paralelo", "estado"), name="insc_paralelo_estado_idx"),
            models.Index(fields=("estudiante", "estado"), name="insc_est_estado_idx"),
        ]
        verbose_name = "inscripción"
        verbose_name_plural = "inscripciones"

    def clean(self):
        if self.estado != self.Estado.CURSANDO or not self.estudiante_id or not self.paralelo_id:
            return

        ocupados = Inscripcion.objects.filter(
            paralelo_id=self.paralelo_id, estado=self.Estado.CURSANDO
        )
        if self.pk:
            ocupados = ocupados.exclude(pk=self.pk)
        if ocupados.count() >= self.paralelo.cupo_maximo:
            raise ValidationError({"paralelo": "El paralelo ya alcanzó su cupo máximo."})

        misma_materia = Inscripcion.objects.filter(
            estudiante_id=self.estudiante_id,
            paralelo__materia_id=self.paralelo.materia_id,
            paralelo__periodo_id=self.paralelo.periodo_id,
            estado=self.Estado.CURSANDO,
        )
        if self.pk:
            misma_materia = misma_materia.exclude(pk=self.pk)
        if misma_materia.exists():
            raise ValidationError("El estudiante ya cursa esta materia en el periodo.")

    def __str__(self):
        return f"{self.estudiante} · {self.paralelo} · {self.get_estado_display()}"
