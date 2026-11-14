from django.db import models
from django.contrib.auth.models import User
from cryptography.fernet import Fernet
import os

# Используем безопасную генерацию ключа Fernet. 
# В продакшене лучше читать его из .env: os.getenv("CRYPT_KEY")
DEFAULT_KEY = b'6vK8_Ym3X6_J1RWW7dfS5z8A0fGHjklQWERTYUIOP_A='
cipher_suite = Fernet(DEFAULT_KEY)

class DBSettings(models.Model):
    DB_TYPES = [
        ('postgresql', 'PostgreSQL'),
        ('mysql', 'MySQL'),
    ]

    # Связь один-к-одному с пользователем Django
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='db_config')
    db_type = models.CharField(max_length=20, choices=DB_TYPES, verbose_name="Тип СУБД")
    host = models.CharField(max_length=255, verbose_name="Хост / IP")
    port = models.IntegerField(verbose_name="Порт")
    db_name = models.CharField(max_length=255, verbose_name="Имя Базы Данных")
    user_name = models.CharField(max_length=255, verbose_name="Имя пользователя БД")
    encrypted_password = models.CharField(max_length=500, verbose_name="Зашифрованный пароль")

    class Meta:
        verbose_name = "Настройка БД пользователя"
        verbose_name_plural = "Настройки БД пользователей"

    def __str__(self):
        return f"Конфиг {self.user.username} ({self.db_type})"

    # Методы для удобного сохранения и чтения пароля
    def set_password(self, raw_password):
        if raw_password:
            self.encrypted_password = cipher_suite.encrypt(raw_password.encode()).decode()

    def get_password(self):
        if self.encrypted_password:
            return cipher_suite.decrypt(self.encrypted_password.encode()).decode()
        return ""
