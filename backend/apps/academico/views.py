from django.db.models import Count, Prefetch
from rest_framework import viewsets
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import AllowAny

from .models import Carrera, Materia, PeriodoAcademico, PlanEstudio, Prerrequisito
from .serializers import (
    CarreraSerializer,
    MateriaSerializer,
    PeriodoAcademicoSerializer,
    PlanEstudioSerializer,
)


class CarreraViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Carrera.objects.all()
    serializer_class = CarreraSerializer
    permission_classes = (AllowAny,)


class PlanEstudioViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = PlanEstudio.objects.select_related("carrera").annotate(
        cantidad_materias=Count("materias")
    )
    serializer_class = PlanEstudioSerializer
    permission_classes = (AllowAny,)


class MateriaViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = MateriaSerializer
    permission_classes = (AllowAny,)

    def get_queryset(self):
        queryset = Materia.objects.select_related("plan", "plan__carrera").prefetch_related(
            Prefetch(
                "prerrequisitos",
                queryset=Prerrequisito.objects.select_related("requisito"),
            )
        )
        plan_id = self.request.query_params.get("plan")
        if plan_id:
            try:
                plan_id = int(plan_id)
            except ValueError as exc:
                raise ValidationError(
                    {"plan": "Debe ser el identificador numérico de un plan."}
                ) from exc
            queryset = queryset.filter(plan_id=plan_id)

        semestre = self.request.query_params.get("semestre")
        if semestre:
            try:
                semestre = int(semestre)
            except ValueError as exc:
                raise ValidationError(
                    {"semestre": "Debe ser un número de semestre válido."}
                ) from exc
            queryset = queryset.filter(semestre_sugerido=semestre)

        return queryset


class PeriodoAcademicoViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = PeriodoAcademico.objects.all()
    serializer_class = PeriodoAcademicoSerializer
    permission_classes = (AllowAny,)
