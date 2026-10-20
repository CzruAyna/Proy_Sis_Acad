from django.contrib import admin

from .models import Acta, CorreccionNota, Nota


class NotaInline(admin.TabularInline):
    model = Nota
    extra = 0
    autocomplete_fields = ("inscripcion",)

    def has_add_permission(self, request, obj=None):
        return super().has_add_permission(request, obj) and not (obj and obj.cerrada)

    def get_readonly_fields(self, request, obj=None):
        if obj and obj.cerrada:
            return tuple(field.name for field in self.model._meta.fields)
        return super().get_readonly_fields(request, obj)


@admin.register(Acta)
class ActaAdmin(admin.ModelAdmin):
    list_display = ("paralelo", "cerrada", "creada_en", "cerrada_en", "cerrada_por")
    list_filter = ("cerrada", "paralelo__periodo", "paralelo__materia__plan__carrera")
    search_fields = ("paralelo__materia__codigo", "paralelo__materia__nombre", "paralelo__identificador")
    autocomplete_fields = ("paralelo",)
    inlines = (NotaInline,)

    def get_readonly_fields(self, request, obj=None):
        if obj and obj.cerrada:
            return tuple(field.name for field in self.model._meta.fields)
        return ("creada_en", "cerrada_en", "cerrada_por")

    def has_delete_permission(self, request, obj=None):
        return super().has_delete_permission(request, obj) and not (obj and obj.cerrada)

    def get_actions(self, request):
        actions = super().get_actions(request)
        actions.pop("delete_selected", None)
        return actions


@admin.register(Nota)
class NotaAdmin(admin.ModelAdmin):
    list_display = ("inscripcion", "acta", "puntaje", "actualizada_en")
    list_filter = ("acta__cerrada", "acta__paralelo__periodo")
    search_fields = ("inscripcion__estudiante__username", "inscripcion__estudiante__ci", "acta__paralelo__materia__codigo")
    autocomplete_fields = ("acta", "inscripcion")

    def get_readonly_fields(self, request, obj=None):
        if obj and obj.acta.cerrada:
            return tuple(field.name for field in self.model._meta.fields)
        return ("actualizada_en",)

    def has_delete_permission(self, request, obj=None):
        return super().has_delete_permission(request, obj) and not (obj and obj.acta.cerrada)

    def get_actions(self, request):
        actions = super().get_actions(request)
        actions.pop("delete_selected", None)
        return actions


@admin.register(CorreccionNota)
class CorreccionNotaAdmin(admin.ModelAdmin):
    list_display = ("nota", "puntaje_anterior", "puntaje_nuevo", "referencia_tramite", "corregida_por", "creada_en")
    list_filter = ("creada_en",)
    search_fields = ("referencia_tramite", "nota__inscripcion__estudiante__username")
    readonly_fields = tuple(field.name for field in CorreccionNota._meta.fields)

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
