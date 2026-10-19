import django.core.validators
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Carrera",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("nombre", models.CharField(max_length=160)),
                ("codigo", models.CharField(max_length=20, unique=True)),
            ],
            options={"ordering": ("nombre",), "verbose_name": "carrera", "verbose_name_plural": "carreras"},
        ),
        migrations.CreateModel(
            name="PeriodoAcademico",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "tipo",
                    models.CharField(
                        choices=[
                            ("S1", "Primer semestre"),
                            ("S2", "Segundo semestre"),
                            ("ANUAL", "Anual"),
                            ("VERANO", "Verano"),
                            ("INVIERNO", "Invierno"),
                            ("MESA", "Mesa de examen"),
                        ],
                        max_length=10,
                    ),
                ),
                (
                    "anio",
                    models.PositiveSmallIntegerField(
                        validators=[
                            django.core.validators.MinValueValidator(2000),
                            django.core.validators.MaxValueValidator(2200),
                        ]
                    ),
                ),
                (
                    "orden",
                    models.PositiveSmallIntegerField(
                        validators=[
                            django.core.validators.MinValueValidator(1),
                            django.core.validators.MaxValueValidator(99),
                        ]
                    ),
                ),
                ("activo", models.BooleanField(default=False)),
            ],
            options={
                "ordering": ("-anio", "orden"),
                "verbose_name": "periodo académico",
                "verbose_name_plural": "periodos académicos",
            },
        ),
        migrations.CreateModel(
            name="PlanEstudio",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("nombre", models.CharField(max_length=120)),
                ("vigente", models.BooleanField(default=True)),
                (
                    "carrera",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.PROTECT,
                        related_name="planes",
                        to="academico.carrera",
                    ),
                ),
            ],
            options={
                "ordering": ("carrera__nombre", "nombre"),
                "verbose_name": "plan de estudio",
                "verbose_name_plural": "planes de estudio",
            },
        ),
        migrations.AddConstraint(
            model_name="planestudio",
            constraint=models.UniqueConstraint(
                fields=("carrera", "nombre"),
                name="academico_plan_carrera_nombre_uniq",
            ),
        ),
        migrations.CreateModel(
            name="Materia",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("codigo", models.CharField(max_length=30, unique=True)),
                ("nombre", models.CharField(max_length=160)),
                (
                    "creditos",
                    models.DecimalField(
                        decimal_places=2,
                        max_digits=5,
                        validators=[django.core.validators.MinValueValidator(0)],
                    ),
                ),
                (
                    "semestre_sugerido",
                    models.PositiveSmallIntegerField(
                        validators=[django.core.validators.MinValueValidator(1)]
                    ),
                ),
                ("es_extracurricular", models.BooleanField(default=False)),
                ("lleva_auxiliatura", models.BooleanField(default=False)),
                (
                    "plan",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.PROTECT,
                        related_name="materias",
                        to="academico.planestudio",
                    ),
                ),
            ],
            options={"ordering": ("plan", "semestre_sugerido", "codigo"), "verbose_name": "materia", "verbose_name_plural": "materias"},
        ),
        migrations.CreateModel(
            name="Prerrequisito",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("es_corequisito", models.BooleanField(default=False)),
                (
                    "materia",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="prerrequisitos",
                        to="academico.materia",
                    ),
                ),
                (
                    "requisito",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.PROTECT,
                        related_name="habilita_a",
                        to="academico.materia",
                    ),
                ),
            ],
            options={
                "ordering": ("materia__codigo", "requisito__codigo"),
                "verbose_name": "prerrequisito",
                "verbose_name_plural": "prerrequisitos",
            },
        ),
        migrations.AddConstraint(
            model_name="prerrequisito",
            constraint=models.UniqueConstraint(
                fields=("materia", "requisito"),
                name="academico_prerrequisito_par_uniq",
            ),
        ),
        migrations.AddConstraint(
            model_name="prerrequisito",
            constraint=models.CheckConstraint(
                check=~models.Q(materia=models.F("requisito")),
                name="academico_prerrequisito_no_self",
            ),
        ),
        migrations.AddConstraint(
            model_name="periodoacademico",
            constraint=models.UniqueConstraint(
                fields=("anio", "orden"),
                name="academico_periodo_anio_orden_uniq",
            ),
        ),
    ]
