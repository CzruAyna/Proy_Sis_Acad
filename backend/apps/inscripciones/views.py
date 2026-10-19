from rest_framework import status, viewsets
from rest_framework.response import Response

from .models import Inscripcion
from .permissions import EsEstudiante
from .serializers import CrearInscripcionSerializer, InscripcionSerializer
from .services import inscribir_en_paralelo, retirar_inscripcion


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
