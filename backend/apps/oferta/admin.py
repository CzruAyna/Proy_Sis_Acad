from django.contrib import admin

from .models import Aula, DocenteMateria, Paralelo, SesionClase


@admin.register(Aula)
class AulaAdmin(admin.ModelAdmin):
    list_display = ("nombre", "capacidad", "es_laboratorio")
    list_filter = ("es_laboratorio",)
    search_fields = ("nombre",)


@admin.register(DocenteMateria)
class DocenteMateriaAdmin(admin.ModelAdmin):
    list_display = ("docente", "materia")
    list_filter = ("materia__plan__carrera",)
    search_fields = ("docente__username", "docente__first_name", "materia__codigo", "materia__nombre")
    autocomplete_fields = ("docente", "materia")


class SesionClaseInline(admin.TabularInline):
    model = SesionClase
    extra = 0
    autocomplete_fields = ("aula",)


@admin.register(Paralelo)
class ParaleloAdmin(admin.ModelAdmin):
    list_display = ("materia", "identificador", "periodo", "docente", "cupo_maximo", "abierto")
    list_filter = ("abierto", "periodo", "materia__plan__carrera")
    search_fields = ("materia__codigo", "materia__nombre", "identificador")
    autocomplete_fields = ("materia", "docente")
    inlines = (SesionClaseInline,)


admin.site.register(SesionClase)
