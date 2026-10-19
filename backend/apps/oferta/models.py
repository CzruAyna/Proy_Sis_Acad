from django.core.exceptions import ValidationError
from django.core.validators import MinValueValidator
from django.db import models

from apps.academico.models import Materia, PeriodoAcademico
from apps.usuarios.models import Usuario


class Aula(models.Model):
    nombre = models.CharField(max_length=80, unique=True)
    capacidad = models.PositiveSmallIntegerField(validators=[MinValueValidator(1)])
    es_laboratorio = models.BooleanField(default=False)

    class Meta:
        ordering = ("nombre",)
        verbose_name = "aula"
        verbose_name_plural = "aulas"

    def __str__(self):
        return self.nombre


class DocenteMateria(models.Model):
    docente = models.ForeignKey(
        Usuario, on_delete=models.PROTECT, related_name="materias_dictables"
    )
    materia = models.ForeignKey(
        Materia, on_delete=models.PROTECT, related_name="docentes_habilitados"
    )

    class Meta:
        ordering = ("materia__codigo", "docente__last_name", "docente__first_name")
        constraints = [
            models.UniqueConstraint(
                fields=("docente", "materia"), name="oferta_docente_materia_uniq"
            )
        ]
        verbose_name = "materia habilitada para docente"
        verbose_name_plural = "materias habilitadas para docentes"

    def clean(self):
        if self.docente_id and self.docente.rol != Usuario.Rol.DOCENTE:
            raise ValidationError({"docente": "El usuario debe tener rol docente."})

    def __str__(self):
        return f"{self.docente} · {self.materia.codigo}"


class Paralelo(models.Model):
    materia = models.ForeignKey(
        Materia, on_delete=models.PROTECT, related_name="paralelos"
    )
    periodo = models.ForeignKey(
        PeriodoAcademico, on_delete=models.PROTECT, related_name="paralelos"
    )
    identificador = models.CharField(max_length=8)
    docente = models.ForeignKey(
        Usuario,
        on_delete=models.PROTECT,
        related_name="paralelos_dictados",
        null=True,
        blank=True,
        limit_choices_to={"rol": Usuario.Rol.DOCENTE},
    )
    cupo_maximo = models.PositiveSmallIntegerField(validators=[MinValueValidator(1)])
    abierto = models.BooleanField(default=False)

    class Meta:
        ordering = ("materia__codigo", "identificador")
        constraints = [
            models.UniqueConstraint(
                fields=("materia", "periodo", "identificador"),
                name="oferta_paralelo_materia_periodo_id_uniq",
            )
        ]
        verbose_name = "paralelo"
        verbose_name_plural = "paralelos"

    def clean(self):
        if self.docente_id and self.docente.rol != Usuario.Rol.DOCENTE:
            raise ValidationError({"docente": "El usuario debe tener rol docente."})
        if self.docente_id and self.materia_id:
            if not DocenteMateria.objects.filter(
                docente_id=self.docente_id, materia_id=self.materia_id
            ).exists():
                raise ValidationError(
                    {"docente": "El docente no está habilitado para esta materia."}
                )
        if self.pk:
            for aula_id, capacidad in self.sesiones.values_list(
                "aula_id", "aula__capacidad"
            ):
                if self.cupo_maximo > capacidad:
                    raise ValidationError(
                        {"cupo_maximo": f"Supera la capacidad del aula {aula_id}."}
                    )

    def __str__(self):
        return f"{self.materia.codigo} · {self.identificador} · {self.periodo}"


class SesionClase(models.Model):
    class Tipo(models.TextChoices):
        TEORIA = "TEORIA", "Teoría"
        LABORATORIO = "LABORATORIO", "Laboratorio"
        AYUDANTIA = "AYUDANTIA", "Ayudantía"

    class Dia(models.IntegerChoices):
        LUNES = 1, "Lunes"
        MARTES = 2, "Martes"
        MIERCOLES = 3, "Miércoles"
        JUEVES = 4, "Jueves"
        VIERNES = 5, "Viernes"
        SABADO = 6, "Sábado"
        DOMINGO = 7, "Domingo"

    paralelo = models.ForeignKey(
        Paralelo, on_delete=models.CASCADE, related_name="sesiones"
    )
    tipo = models.CharField(max_length=12, choices=Tipo.choices, default=Tipo.TEORIA)
    grupo_lab = models.PositiveSmallIntegerField(default=1)
    aula = models.ForeignKey(Aula, on_delete=models.PROTECT, related_name="sesiones")
    dia = models.PositiveSmallIntegerField(choices=Dia.choices)
    hora_inicio = models.TimeField()
    hora_fin = models.TimeField()

    class Meta:
        ordering = ("dia", "hora_inicio")
        constraints = [
            models.CheckConstraint(
                check=models.Q(hora_fin__gt=models.F("hora_inicio")),
                name="oferta_sesion_fin_despues_inicio",
            ),
            models.UniqueConstraint(
                fields=("paralelo", "tipo", "grupo_lab", "dia", "hora_inicio"),
                name="oferta_sesion_paralelo_horario_uniq",
            ),
        ]
        verbose_name = "sesión de clase"
        verbose_name_plural = "sesiones de clase"

    def clean(self):
        errors = {}
        if self.hora_inicio and self.hora_fin and self.hora_fin <= self.hora_inicio:
            errors["hora_fin"] = "La hora de término debe ser posterior al inicio."
        if self.aula_id and self.paralelo_id:
            if self.paralelo.cupo_maximo > self.aula.capacidad:
                errors["aula"] = "El cupo del paralelo supera la capacidad del aula."
            if self.tipo == self.Tipo.LABORATORIO and not self.aula.es_laboratorio:
                errors["aula"] = "Las sesiones de laboratorio requieren un aula laboratorio."
        if self.aula_id and self.dia and self.hora_inicio and self.hora_fin:
            cruces = SesionClase.objects.filter(
                aula_id=self.aula_id,
                dia=self.dia,
                hora_inicio__lt=self.hora_fin,
                hora_fin__gt=self.hora_inicio,
            )
            if self.pk:
                cruces = cruces.exclude(pk=self.pk)
            if cruces.exists():
                errors["aula"] = "El aula ya tiene una sesión que se cruza en ese horario."
        if errors:
            raise ValidationError(errors)

    def __str__(self):
        return f"{self.get_dia_display()} {self.hora_inicio:%H:%M}–{self.hora_fin:%H:%M}"
