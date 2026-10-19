from django.contrib import admin

from .models import Carrera, Materia, PeriodoAcademico, PlanEstudio, Prerrequisito


class PlanEstudioInline(admin.TabularInline):
    model = PlanEstudio
    extra = 0


class PrerrequisitoInline(admin.TabularInline):
    model = Prerrequisito
    fk_name = "materia"
    extra = 0
    autocomplete_fields = ("requisito",)


@admin.register(Carrera)
class CarreraAdmin(admin.ModelAdmin):
    list_display = ("codigo", "nombre", "cantidad_planes")
    search_fields = ("codigo", "nombre")
    inlines = (PlanEstudioInline,)

    @admin.display(description="Planes")
    def cantidad_planes(self, obj):
        return obj.planes.count()


@admin.register(PlanEstudio)
class PlanEstudioAdmin(admin.ModelAdmin):
    list_display = ("nombre", "carrera", "vigente", "cantidad_materias")
    list_filter = ("vigente", "carrera")
    search_fields = ("nombre", "carrera__nombre", "carrera__codigo")
    autocomplete_fields = ("carrera",)

    @admin.display(description="Materias")
    def cantidad_materias(self, obj):
        return obj.materias.count()


@admin.register(Materia)
class MateriaAdmin(admin.ModelAdmin):
    list_display = (
        "codigo",
        "nombre",
        "plan",
        "semestre_sugerido",
        "creditos",
        "es_extracurricular",
    )
    list_filter = ("plan__carrera", "plan", "semestre_sugerido", "es_extracurricular")
    search_fields = ("codigo", "nombre", "plan__nombre", "plan__carrera__nombre")
    autocomplete_fields = ("plan",)
    inlines = (PrerrequisitoInline,)


@admin.register(Prerrequisito)
class PrerrequisitoAdmin(admin.ModelAdmin):
    list_display = ("materia", "requisito", "es_corequisito")
    list_filter = ("es_corequisito", "materia__plan__carrera")
    search_fields = ("materia__codigo", "materia__nombre", "requisito__codigo")
    autocomplete_fields = ("materia", "requisito")


@admin.register(PeriodoAcademico)
class PeriodoAcademicoAdmin(admin.ModelAdmin):
    list_display = ("__str__", "tipo", "anio", "orden", "activo")
    list_filter = ("tipo", "anio", "activo")
    ordering = ("-anio", "orden")
