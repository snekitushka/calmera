# Calmera
## Описание
Мобильное приложение для поддержки ментального здоровья с встроенным виртуальным психологом. Позволяет пользователям следить за своим эмоциональным состоянием и получать интерактивную поддержку.
### Функции
- Интерактивное общение с чат-ботом
- Ведение дневника-эмоций
- Каталог упражнений и техник
<div align="center">
  <img height="400" alt="image" src="https://github.com/user-attachments/assets/add43d68-4a2e-424d-a5f7-82c05b1934f8" />
  <img height="400" alt="image" src="https://github.com/user-attachments/assets/187674be-a176-4ecd-ae4a-bfa7d6d0d541" />
  <img height="400" alt="image" src="https://github.com/user-attachments/assets/de024178-432e-49f9-abe3-781c1358761c" />
</div>

### Технический стек
- **Frontend:** Flutter  
- **Backend:** Python (FastAPI)  
- **Контейнеризация:** Docker  
- **Аутентификация:** JWT, OAuth2  
- **Интеграции:** OpenAI API

## Запуск
### 1. Клонируйте репозиторий:

```
git clone https://github.com/snekitushka/calmera.git
cd calmera
```

### 2. Запустите все сервисы:

```
docker-compose up --build
```

### 3. Проверьте статус системы:

```
curl http://localhost:8000/
```
