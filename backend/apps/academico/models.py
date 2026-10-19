from django.core.exceptions import ValidationError
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Carrera(models.Model):
    nombre = models.CharField(max_length=160)
    codigo = models.CharField(max_length=20, unique=True)

    class Meta:
        ordering = ("nombre",)
        verbose_name = "carrera"
        verbose_name_plural = "carreras"

    def __str__(self):
        return f"{self.codigo} · {self.nombre}"


class PlanEstudio(models.Model):
    carrera = models.ForeignKey(
        Carrera, on_delete=models.PROTECT, related_name="planes"
    )
    nombre = models.CharField(max_length=120)
    vigente = models.BooleanField(default=True)

    class Meta:
        ordering = ("carrera__nombre", "nombre")
        constraints = [
            models.UniqueConstraint(
                fields=("carrera", "nombre"), name="academico_plan_carrera_nombre_uniq"
            )
        ]
        verbose_name = "plan de estudio"
        verbose_name_plural = "planes de estudio"

    def __str__(self):
        return f"{self.carrera.codigo} · {self.nombre}"


class Materia(models.Model):
    plan = models.ForeignKey(
        PlanEstudio, on_delete=models.PROTECT, related_name="materias"
    )
    codigo = models.CharField(max_length=30, unique=True)
    nombre = models.CharField(max_length=160)
    creditos = models.DecimalField(
        max_digits=5, decimal_places=2, validators=[MinValueValidator(0)]
    )
    semestre_sugerido = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1)]
    )
    es_extracurricular = models.BooleanField(default=False)
    lleva_auxiliatura = models.BooleanField(default=False)

    class Meta:
        ordering = ("plan", "semestre_sugerido", "codigo")
        verbose_name = "materia"
        verbose_name_plural = "materias"

    def __str__(self):
        return f"{self.codigo} · {self.nombre}"


class Prerrequisito(models.Model):
    materia = models.ForeignKey(
        Materia, on_delete=models.CASCADE, related_name="prerrequisitos"
    )
    requisito = models.ForeignKey(
        Materia, on_delete=models.PROTECT, related_name="habilita_a"
    )
    es_corequisito = models.BooleanField(default=False)

    class Meta:
        ordering = ("materia__codigo", "requisito__codigo")
        constraints = [
            models.UniqueConstraint(
                fields=("materia", "requisito"),
                name="academico_prerrequisito_par_uniq",
            ),
            models.CheckConstraint(
                check=~models.Q(materia=models.F("requisito")),
                name="academico_prerrequisito_no_self",
            ),
        ]
        verbose_name = "prerrequisito"
        verbose_name_plural = "prerrequisitos"

    def clean(self):
        errors = {}

        if self.materia_id and self.requisito_id:
            if self.materia_id == self.requisito_id:
                errors["requisito"] = "Una materia no puede ser requisito de sí misma."
            elif self.materia.plan_id != self.requisito.plan_id:
                errors["requisito"] = (
                    "La materia y su requisito deben pertenecer al mismo plan."
                )
            elif self._creates_cycle():
                errors["requisito"] = (
                    "La relación crea un ciclo en la malla curricular."
                )

        if errors:
            raise ValidationError(errors)

    def _creates_cycle(self):
        pending = [self.requisito_id]
        visited = set()

        while pending:
            current_id = pending.pop()
            if current_id == self.materia_id:
                return True
            if current_id in visited:
                continue
            visited.add(current_id)
            relaciones = Prerrequisito.objects.filter(materia_id=current_id)
            if self.pk:
                relaciones = relaciones.exclude(pk=self.pk)
            pending.extend(relaciones.values_list("requisito_id", flat=True))

        return False

    def __str__(self):
        relation = "corequisito" if self.es_corequisito else "prerrequisito"
        return f"{self.requisito.codigo} → {self.materia.codigo} ({relation})"


class PeriodoAcademico(models.Model):
    class Tipo(models.TextChoices):
        S1 = "S1", "Primer semestre"
        S2 = "S2", "Segundo semestre"
        ANUAL = "ANUAL", "Anual"
        VERANO = "VERANO", "Verano"
        INVIERNO = "INVIERNO", "Invierno"
        MESA = "MESA", "Mesa de examen"

    tipo = models.CharField(max_length=10, choices=Tipo.choices)
    anio = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(2000), MaxValueValidator(2200)]
    )
    orden = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(99)]
    )
    activo = models.BooleanField(default=False)

    class Meta:
        ordering = ("-anio", "orden")
        constraints = [
            models.UniqueConstraint(
                fields=("anio", "orden"), name="academico_periodo_anio_orden_uniq"
            )
        ]
        verbose_name = "periodo académico"
        verbose_name_plural = "periodos académicos"

    def __str__(self):
        return f"{self.get_tipo_display()} {self.anio}"
