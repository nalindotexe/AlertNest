from django.contrib import admin
from django.urls import path, include, re_path
from django.views.static import serve
import os
from django.conf import settings
from django.http import HttpResponse, JsonResponse

flutter_dir = os.path.join(settings.BASE_DIR.parent, 'frontend', 'build', 'web')

def serve_flutter(request, path=''):
    if path != '' and os.path.exists(os.path.join(flutter_dir, path)):
        return serve(request, path, document_root=flutter_dir)
    return serve(request, 'index.html', document_root=flutter_dir)

def root_view(request):
    return JsonResponse({
        "status": "running",
        "message": "AlertNest Backend API is operational",
        "version": "1.0.0"
    })

def favicon_view(request):
    return HttpResponse(status=204)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', lambda r: HttpResponse("OK")),
    path('favicon.ico', favicon_view),
    path('', root_view),
    path('', include('core.urls')),
    re_path(r'^(?P<path>.*)$', serve_flutter),
]
