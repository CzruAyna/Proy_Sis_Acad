from django.contrib.auth.models import AbstractUser
from django.db import models


class Usuario(AbstractUser):
    REQUIRED_FIELDS = ["email", "ci"]

    class Rol(models.TextChoices):
        ESTUDIANTE = "ESTUDIANTE", "Estudiante"
        DOCENTE = "DOCENTE", "Docente"
        AUXILIAR = "AUXILIAR", "Auxiliar de Cátedra"
        ENCARGADO_HORARIOS = "ENCARGADO_HORARIOS", "Encargado de Horarios"
        DIRECTOR = "DIRECTOR", "Director de Carrera"
        ADMIN = "ADMIN", "Administrador"

    ci = models.CharField(max_length=20, unique=True)
    rol = models.CharField(
        max_length=20, choices=Rol.choices, default=Rol.ESTUDIANTE
    )

    def __str__(self):
        return f"{self.username} ({self.get_rol_display()})"
