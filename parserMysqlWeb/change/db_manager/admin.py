from django.contrib import admin
from .models import DBSettings

@admin.register(DBSettings)
class DBSettingsAdmin(admin.ModelAdmin):
    list_display = ('user', 'db_type', 'host', 'db_name')
    search_fields = ('user__username', 'db_name')
