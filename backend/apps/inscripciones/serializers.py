from rest_framework import serializers

from apps.oferta.serializers import ParaleloSerializer

from .models import Inscripcion


class CrearInscripcionSerializer(serializers.Serializer):
    paralelo_id = serializers.IntegerField(min_value=1)


class InscripcionSerializer(serializers.ModelSerializer):
    paralelo_info = ParaleloSerializer(source="paralelo", read_only=True)
    estado_display = serializers.CharField(source="get_estado_display", read_only=True)
    origen_display = serializers.CharField(source="get_origen_display", read_only=True)

    class Meta:
        model = Inscripcion
        fields = (
            "id",
            "paralelo",
            "paralelo_info",
            "estado",
            "estado_display",
            "origen",
            "origen_display",
            "creado_en",
        )
        read_only_fields = fields
