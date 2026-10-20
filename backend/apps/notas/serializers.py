from decimal import Decimal

from rest_framework import serializers

from apps.inscripciones.models import Inscripcion

from .models import Acta, CorreccionNota, Nota


class NotaEntradaSerializer(serializers.Serializer):
    inscripcion_id = serializers.IntegerField(min_value=1)
    puntaje = serializers.DecimalField(
        max_digits=5,
        decimal_places=2,
        min_value=Decimal("0"),
        max_value=Decimal("100"),
    )


class CorreccionEntradaSerializer(serializers.Serializer):
    nota_id = serializers.IntegerField(min_value=1)
    puntaje = serializers.DecimalField(
        max_digits=5,
        decimal_places=2,
        min_value=Decimal("0"),
        max_value=Decimal("100"),
    )
    motivo = serializers.CharField(min_length=10, max_length=2000)
    referencia_tramite = serializers.CharField(min_length=3, max_length=80)


class RegistroActaSerializer(serializers.ModelSerializer):
    estudiante_id = serializers.IntegerField(source="estudiante.id", read_only=True)
    estudiante = serializers.SerializerMethodField()
    puntaje = serializers.SerializerMethodField()

    class Meta:
        model = Inscripcion
        fields = ("id", "estudiante_id", "estudiante", "estado", "puntaje")

    def get_estudiante(self, obj):
        nombre = obj.estudiante.get_full_name()
        return nombre or obj.estudiante.username

    def get_puntaje(self, obj):
        try:
            return obj.nota.puntaje
        except Nota.DoesNotExist:
            return None


class ActaSerializer(serializers.ModelSerializer):
    paralelo_codigo = serializers.CharField(source="paralelo.materia.codigo", read_only=True)
    paralelo_materia = serializers.CharField(source="paralelo.materia.nombre", read_only=True)
    paralelo_identificador = serializers.CharField(source="paralelo.identificador", read_only=True)
    periodo = serializers.SerializerMethodField()
    docente = serializers.SerializerMethodField()
    inscripciones = serializers.SerializerMethodField()
    cerrada_por_nombre = serializers.SerializerMethodField()

    class Meta:
        model = Acta
        fields = (
            "id",
            "paralelo",
            "paralelo_codigo",
            "paralelo_materia",
            "paralelo_identificador",
            "periodo",
            "docente",
            "cerrada",
            "creada_en",
            "cerrada_en",
            "cerrada_por_nombre",
            "inscripciones",
        )

    def get_docente(self, obj):
        if not obj.paralelo.docente_id:
            return "Por asignar"
        docente = obj.paralelo.docente
        return docente.get_full_name() or docente.username

    def get_periodo(self, obj):
        return str(obj.paralelo.periodo)

    def get_inscripciones(self, obj):
        queryset = obj.paralelo.inscripciones.exclude(
            estado=Inscripcion.Estado.RETIRADA
        ).select_related("estudiante").prefetch_related("nota")
        return RegistroActaSerializer(queryset, many=True).data

    def get_cerrada_por_nombre(self, obj):
        if not obj.cerrada_por_id:
            return None
        return obj.cerrada_por.get_full_name() or obj.cerrada_por.username


class CorreccionNotaSerializer(serializers.ModelSerializer):
    corregida_por_nombre = serializers.SerializerMethodField()

    class Meta:
        model = CorreccionNota
        fields = (
            "id",
            "nota",
            "puntaje_anterior",
            "puntaje_nuevo",
            "motivo",
            "referencia_tramite",
            "corregida_por_nombre",
            "creada_en",
        )

    def get_corregida_por_nombre(self, obj):
        return obj.corregida_por.get_full_name() or obj.corregida_por.username
