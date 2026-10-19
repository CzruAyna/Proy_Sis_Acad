from django.contrib import admin
from django.http import JsonResponse
from django.urls import include, path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from apps.academico.views import (
    CarreraViewSet,
    MateriaViewSet,
    PeriodoAcademicoViewSet,
    PlanEstudioViewSet,
)
from apps.oferta.views import ParaleloViewSet


router = DefaultRouter()
router.register("carreras", CarreraViewSet)
router.register("mallas", PlanEstudioViewSet)
router.register("materias", MateriaViewSet, basename="materia")
router.register("periodos", PeriodoAcademicoViewSet)
router.register("paralelos", ParaleloViewSet, basename="paralelo")


def health(request):
    return JsonResponse({"status": "ok"})


urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", health),
    path("api/", include(router.urls)),
    path("api/token/", TokenObtainPairView.as_view()),
    path("api/token/refresh/", TokenRefreshView.as_view()),
]
