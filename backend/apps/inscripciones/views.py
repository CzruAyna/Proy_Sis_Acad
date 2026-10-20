from django.db.models import Count, Q
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response

from apps.academico.models import PeriodoAcademico
from apps.oferta.models import Paralelo
from apps.oferta.serializers import ParaleloSerializer

from .models import Inscripcion
from .permissions import EsEstudiante
from .serializers import CrearInscripcionSerializer, InscripcionSerializer
from .services import evaluar_inscripcion, inscribir_en_paralelo, retirar_inscripcion


class InscripcionViewSet(viewsets.GenericViewSet):
    serializer_class = InscripcionSerializer
    permission_classes = (EsEstudiante,)

    def get_queryset(self):
        return Inscripcion.objects.filter(estudiante=self.request.user).select_related(
            "paralelo",
            "paralelo__materia",
            "paralelo__periodo",
            "paralelo__docente",
        ).prefetch_related("paralelo__sesiones", "paralelo__sesiones__aula")

    def list(self, request):
        serializer = self.get_serializer(self.get_queryset(), many=True)
        return Response(serializer.data)

    @action(detail=False, methods=("get",), url_path="elegibilidad")
    def elegibilidad(self, request):
        periodo_id = request.query_params.get("periodo")
        try:
            periodo_id = int(periodo_id)
        except (TypeError, ValueError) as exc:
            raise ValidationError({"periodo": "Indica un periodo académico válido."}) from exc
        periodo = PeriodoAcademico.objects.filter(pk=periodo_id).first()
        if periodo is None:
            raise ValidationError({"periodo": "No existe ese periodo académico."})

        paralelos = Paralelo.objects.filter(
            abierto=True, periodo=periodo
        ).annotate(
            cantidad_inscriptos=Count(
                "inscripciones",
                filter=Q(inscripciones__estado=Inscripcion.Estado.CURSANDO),
            )
        ).select_related("materia", "periodo", "docente").prefetch_related(
            "sesiones", "sesiones__aula"
        )
        resultados = []
        for paralelo in paralelos:
            resultado = ParaleloSerializer(paralelo).data
            resultado["elegibilidad"] = evaluar_inscripcion(request.user, paralelo)
            resultados.append(resultado)
        return Response(resultados)

    def create(self, request):
        entrada = CrearInscripcionSerializer(data=request.data)
        entrada.is_valid(raise_exception=True)
        inscripcion = inscribir_en_paralelo(
            request.user, entrada.validated_data["paralelo_id"]
        )
        return Response(
            self.get_serializer(inscripcion).data, status=status.HTTP_201_CREATED
        )

    def destroy(self, request, pk=None):
        inscripcion = retirar_inscripcion(pk, request.user)
        return Response(self.get_serializer(inscripcion).data)
