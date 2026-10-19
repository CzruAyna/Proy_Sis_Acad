from rest_framework import serializers

from .models import Paralelo


class SesionClaseSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    tipo = serializers.CharField(read_only=True)
    tipo_display = serializers.CharField(source="get_tipo_display", read_only=True)
    grupo_lab = serializers.IntegerField(read_only=True)
    aula = serializers.CharField(source="aula.nombre", read_only=True)
    dia = serializers.IntegerField(read_only=True)
    dia_display = serializers.CharField(source="get_dia_display", read_only=True)
    hora_inicio = serializers.TimeField(read_only=True)
    hora_fin = serializers.TimeField(read_only=True)


class ParaleloSerializer(serializers.ModelSerializer):
    materia_codigo = serializers.CharField(source="materia.codigo", read_only=True)
    materia_nombre = serializers.CharField(source="materia.nombre", read_only=True)
    periodo_tipo = serializers.CharField(source="periodo.get_tipo_display", read_only=True)
    periodo_anio = serializers.IntegerField(source="periodo.anio", read_only=True)
    docente_nombre = serializers.SerializerMethodField()
    sesiones = SesionClaseSerializer(many=True, read_only=True)
    inscriptos_actuales = serializers.SerializerMethodField()
    cupos_disponibles = serializers.SerializerMethodField()

    class Meta:
        model = Paralelo
        fields = (
            "id",
            "materia",
            "materia_codigo",
            "materia_nombre",
            "periodo",
            "periodo_tipo",
            "periodo_anio",
            "identificador",
            "docente_nombre",
            "cupo_maximo",
            "inscriptos_actuales",
            "cupos_disponibles",
            "abierto",
            "sesiones",
        )

    def get_docente_nombre(self, obj):
        if not obj.docente_id:
            return "Por asignar"
        return obj.docente.get_full_name() or obj.docente.username

    def get_inscriptos_actuales(self, obj):
        cantidad = getattr(obj, "cantidad_inscriptos", None)
        if cantidad is not None:
            return cantidad
        return obj.inscripciones.filter(estado="CURSANDO").count()

    def get_cupos_disponibles(self, obj):
        return max(0, obj.cupo_maximo - self.get_inscriptos_actuales(obj))
