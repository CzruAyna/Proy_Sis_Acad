from rest_framework import serializers

from .models import Carrera, Materia, PeriodoAcademico, PlanEstudio, Prerrequisito


class CarreraSerializer(serializers.ModelSerializer):
    class Meta:
        model = Carrera
        fields = ("id", "nombre", "codigo")


class PlanEstudioSerializer(serializers.ModelSerializer):
    carrera_codigo = serializers.CharField(source="carrera.codigo", read_only=True)
    carrera_nombre = serializers.CharField(source="carrera.nombre", read_only=True)
    cantidad_materias = serializers.IntegerField(read_only=True)

    class Meta:
        model = PlanEstudio
        fields = (
            "id",
            "carrera",
            "carrera_codigo",
            "carrera_nombre",
            "nombre",
            "vigente",
            "cantidad_materias",
        )


class PrerrequisitoSerializer(serializers.ModelSerializer):
    codigo = serializers.CharField(source="requisito.codigo", read_only=True)
    nombre = serializers.CharField(source="requisito.nombre", read_only=True)

    class Meta:
        model = Prerrequisito
        fields = ("id", "codigo", "nombre", "es_corequisito")


class MateriaSerializer(serializers.ModelSerializer):
    prerrequisitos = PrerrequisitoSerializer(many=True, read_only=True)
    plan_nombre = serializers.CharField(source="plan.nombre", read_only=True)
    carrera_nombre = serializers.CharField(
        source="plan.carrera.nombre", read_only=True
    )

    class Meta:
        model = Materia
        fields = (
            "id",
            "plan",
            "plan_nombre",
            "carrera_nombre",
            "codigo",
            "nombre",
            "creditos",
            "semestre_sugerido",
            "es_extracurricular",
            "lleva_auxiliatura",
            "prerrequisitos",
        )


class PeriodoAcademicoSerializer(serializers.ModelSerializer):
    tipo_display = serializers.CharField(source="get_tipo_display", read_only=True)

    class Meta:
        model = PeriodoAcademico
        fields = ("id", "tipo", "tipo_display", "anio", "orden", "activo")
