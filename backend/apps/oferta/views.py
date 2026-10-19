from rest_framework import viewsets
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import AllowAny

from .models import Paralelo
from .serializers import ParaleloSerializer


class ParaleloViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = ParaleloSerializer
    permission_classes = (AllowAny,)

    def get_queryset(self):
        queryset = Paralelo.objects.filter(abierto=True).select_related(
            "materia", "periodo", "docente"
        ).prefetch_related("sesiones", "sesiones__aula")
        for parameter in ("periodo", "materia"):
            value = self.request.query_params.get(parameter)
            if value:
                try:
                    value = int(value)
                except ValueError as exc:
                    raise ValidationError(
                        {parameter: "Debe ser un identificador numérico."}
                    ) from exc
                queryset = queryset.filter(**{f"{parameter}_id": value})
        return queryset
