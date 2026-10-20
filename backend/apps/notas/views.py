from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response

from apps.usuarios.models import Usuario

from .models import Acta, CorreccionNota
from .permissions import GestionActasPermission
from .serializers import (
    ActaSerializer,
    CorreccionEntradaSerializer,
    CorreccionNotaSerializer,
    NotaEntradaSerializer,
)
from .services import cerrar_acta, corregir_nota, guardar_notas


class ActaViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = ActaSerializer
    permission_classes = (GestionActasPermission,)

    def get_queryset(self):
        queryset = Acta.objects.select_related(
            "paralelo",
            "paralelo__materia",
            "paralelo__periodo",
            "paralelo__docente",
            "cerrada_por",
        ).prefetch_related("paralelo__inscripciones", "paralelo__inscripciones__estudiante")
        user = self.request.user
        if user.rol == Usuario.Rol.DOCENTE and not user.is_superuser:
            queryset = queryset.filter(paralelo__docente=user)
        return queryset

    @action(detail=True, methods=("put",), url_path="notas")
    def notas(self, request, pk=None):
        acta = self.get_object()
        entrada = NotaEntradaSerializer(data=request.data.get("notas"), many=True)
        entrada.is_valid(raise_exception=True)
        guardadas = guardar_notas(acta.pk, request.user, entrada.validated_data)
        return Response(
            {"guardadas": len(guardadas), "acta": self.get_serializer(acta).data}
        )

    @action(detail=True, methods=("post",), url_path="cerrar")
    def cerrar(self, request, pk=None):
        acta = self.get_object()
        acta = cerrar_acta(acta.pk, request.user)
        return Response(self.get_serializer(acta).data)

    @action(detail=True, methods=("post",), url_path="correcciones")
    def correcciones(self, request, pk=None):
        acta = self.get_object()
        if not (
            request.user.is_superuser
            or request.user.rol in (Usuario.Rol.ADMIN, Usuario.Rol.DIRECTOR)
        ):
            raise PermissionDenied("Solo Dirección o Administración pueden corregir actas.")
        entrada = CorreccionEntradaSerializer(data=request.data)
        entrada.is_valid(raise_exception=True)
        correccion = corregir_nota(
            acta.pk,
            request.user,
            entrada.validated_data["nota_id"],
            entrada.validated_data["puntaje"],
            entrada.validated_data["motivo"],
            entrada.validated_data["referencia_tramite"],
        )
        return Response(
            CorreccionNotaSerializer(correccion).data,
            status=status.HTTP_201_CREATED,
        )
