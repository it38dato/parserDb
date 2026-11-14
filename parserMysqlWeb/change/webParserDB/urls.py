from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),          # Панель администратора
    #path('', include('db_manager/urls.py')),   # Все остальные страницы
    path('', include('db_manager.urls')),

]
