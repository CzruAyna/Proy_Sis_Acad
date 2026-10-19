from django.contrib import admin

from .models import Inscripcion


@admin.register(Inscripcion)
class InscripcionAdmin(admin.ModelAdmin):
    list_display = ("estudiante", "paralelo", "estado", "origen", "creado_en")
    list_filter = ("estado", "origen", "paralelo__periodo")
    search_fields = (
        "estudiante__username",
        "estudiante__ci",
        "paralelo__materia__codigo",
        "paralelo__identificador",
    )
    autocomplete_fields = ("estudiante", "paralelo")
    readonly_fields = ("creado_en", "actualizado_en")
