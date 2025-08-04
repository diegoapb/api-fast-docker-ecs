# Simple FastAPI Application

Una API simple construida con FastAPI para demostrar containerización y despliegue en AWS.

## Características

- ✅ API RESTful con FastAPI
- ✅ Operaciones CRUD completas para items
- ✅ Validación de datos con Pydantic
- ✅ Documentación automática con Swagger UI
- ✅ Containerizada con Docker
- ✅ Lista para despliegue en AWS ECS

## Endpoints

- `GET /` - Mensaje de bienvenida
- `GET /health` - Health check
- `GET /items` - Obtener todos los items
- `GET /items/{id}` - Obtener item por ID
- `POST /items` - Crear nuevo item
- `PUT /items/{id}` - Actualizar item
- `DELETE /items/{id}` - Eliminar item

## Desarrollo Local

### Opción 1: Ejecutar directamente con Python

```bash
# Instalar dependencias
pip install -r requirements.txt

# Ejecutar la aplicación
python main.py
```

### Opción 2: Usar Docker Compose (Recomendado)

```bash
# Construir y ejecutar
docker-compose up --build

# Ejecutar en segundo plano
docker-compose up -d --build
```

### Opción 3: Docker manual

```bash
# Construir imagen
docker build -t simple-api .

# Ejecutar contenedor
docker run -p 8000:8000 simple-api
```

## Acceso a la API

Una vez ejecutada, la API estará disponible en:

- **API**: http://localhost:8000
- **Documentación Swagger**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Ejemplo de uso

### Crear un item
```bash
curl -X POST "http://localhost:8000/items" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Laptop",
       "description": "Una laptop para desarrollo",
       "price": 999.99,
       "is_available": true
     }'
```

### Obtener todos los items
```bash
curl "http://localhost:8000/items"
```

## Despliegue en AWS

### Preparar para AWS ECS

1. **Construir y subir imagen a ECR**:
```bash
# Configurar AWS CLI
aws configure

# Crear repositorio ECR
aws ecr create-repository --repository-name simple-api

# Obtener comando de login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tagear imagen
docker tag simple-api:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/simple-api:latest

# Subir imagen
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/simple-api:latest
```

2. **Crear Task Definition para ECS**
3. **Crear ECS Service**
4. **Configurar Load Balancer (opcional)**

### Variables de entorno para producción

- `PORT`: Puerto en el que ejecutar la aplicación (default: 8000)

## Estructura del proyecto

```
api/
├── main.py              # Aplicación principal
├── requirements.txt     # Dependencias Python
├── Dockerfile          # Configuración Docker
├── docker-compose.yml  # Configuración Docker Compose
├── .dockerignore       # Archivos ignorados por Docker
└── README.md           # Este archivo
```

## Tecnologías utilizadas

- **FastAPI**: Framework web moderno y rápido
- **Uvicorn**: Servidor ASGI de alto rendimiento
- **Pydantic**: Validación de datos
- **Docker**: Containerización
- **Python 3.11**: Lenguaje de programación
