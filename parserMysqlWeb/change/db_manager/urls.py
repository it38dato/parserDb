from django.urls import path
from django.contrib.auth import views as auth_views
from . import views

urlpatterns = [
    # Авторизация (использует наш шаблон login.html)
    path('login/', auth_views.LoginView.as_view(template_name='db_manager/login.html'), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    
    # Основной интерфейс
    path('', views.dashboard, name='dashboard'),
    path('settings/', views.db_settings, name='db_settings'),
]
