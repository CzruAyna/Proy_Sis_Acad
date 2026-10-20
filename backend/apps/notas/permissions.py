from rest_framework.permissions import BasePermission

from apps.usuarios.models import Usuario


class GestionActasPermission(BasePermission):
    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and (
                request.user.is_superuser
                or request.user.rol
                in (Usuario.Rol.DOCENTE, Usuario.Rol.DIRECTOR, Usuario.Rol.ADMIN)
            )
        )

    def has_object_permission(self, request, view, obj):
        if request.user.is_superuser or request.user.rol in (
            Usuario.Rol.DIRECTOR,
            Usuario.Rol.ADMIN,
        ):
            return True
        return obj.paralelo.docente_id == request.user.pk
