from rest_framework.permissions import BasePermission

from apps.usuarios.models import Usuario


class EsEstudiante(BasePermission):
    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.rol == Usuario.Rol.ESTUDIANTE
        )
