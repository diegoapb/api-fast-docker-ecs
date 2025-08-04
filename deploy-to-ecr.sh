#!/bin/bash

# Script para desplegar imagen Docker a Amazon ECR
# Asegúrate de tener configurado AWS CLI con las credenciales apropiadas

set -e  # Salir si cualquier comando falla

# Configuración - Modifica estas variables según tu entorno
AWS_REGION="us-east-2"  # Cambia por tu región preferida
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPOSITORY_NAME="fast-api-app"  # Nombre del repositorio en ECR
IMAGE_TAG="latest"
PLATFORM="linux/amd64"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Iniciando proceso de despliegue a Amazon ECR${NC}"
echo -e "${BLUE}=========================================${NC}"

# Verificar que AWS CLI esté configurado
echo -e "${YELLOW}📋 Verificando configuración de AWS CLI...${NC}"
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: AWS CLI no está configurado o las credenciales son inválidas${NC}"
    echo -e "${YELLOW}💡 Ejecuta: aws configure${NC}"
    exit 1
fi

echo -e "${GREEN}✅ AWS CLI configurado correctamente${NC}"
echo -e "${BLUE}🔍 Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${BLUE}🌍 Región: ${AWS_REGION}${NC}"

# Crear el repositorio ECR si no existe
echo -e "${YELLOW}📦 Verificando/Creando repositorio ECR...${NC}"
if ! aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} --region ${AWS_REGION} > /dev/null 2>&1; then
    echo -e "${YELLOW}🔨 Creando repositorio ECR: ${REPOSITORY_NAME}${NC}"
    aws ecr create-repository \
        --repository-name ${REPOSITORY_NAME} \
        --region ${AWS_REGION} \
        --image-scanning-configuration scanOnPush=true
    echo -e "${GREEN}✅ Repositorio ECR creado exitosamente${NC}"
else
    echo -e "${GREEN}✅ Repositorio ECR ya existe${NC}"
fi

# Obtener el login token de ECR
echo -e "${YELLOW}🔐 Autenticando con Amazon ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Autenticación exitosa con ECR${NC}"
else
    echo -e "${RED}❌ Error en la autenticación con ECR${NC}"
    exit 1
fi

# Construir la imagen Docker para la plataforma especificada
echo -e "${YELLOW}🔨 Construyendo imagen Docker para ${PLATFORM}...${NC}"
docker build --platform ${PLATFORM} --no-cache --pull -t ${REPOSITORY_NAME}:${IMAGE_TAG} .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Imagen construida exitosamente${NC}"
else
    echo -e "${RED}❌ Error al construir la imagen${NC}"
    exit 1
fi

# Etiquetar la imagen para ECR
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_TAG}"
echo -e "${YELLOW}🏷️  Etiquetando imagen para ECR...${NC}"
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${ECR_URI}

# Subir la imagen a ECR
echo -e "${YELLOW}⬆️  Subiendo imagen a ECR...${NC}"
docker push ${ECR_URI}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡Imagen subida exitosamente a ECR!${NC}"
    echo -e "${BLUE}📍 URI de la imagen: ${ECR_URI}${NC}"
else
    echo -e "${RED}❌ Error al subir la imagen a ECR${NC}"
    exit 1
fi

# Obtener información adicional
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}📊 INFORMACIÓN DE DESPLIEGUE${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}🏷️  Repositorio: ${REPOSITORY_NAME}${NC}"
echo -e "${BLUE}🔖 Tag: ${IMAGE_TAG}${NC}"
echo -e "${BLUE}🌍 Región: ${AWS_REGION}${NC}"
echo -e "${BLUE}💻 Plataforma: ${PLATFORM}${NC}"
echo -e "${BLUE}📍 URI completa: ${ECR_URI}${NC}"
echo -e "${BLUE}=========================================${NC}"

# Mostrar las imágenes en el repositorio
echo -e "${YELLOW}📋 Imágenes disponibles en el repositorio:${NC}"
aws ecr list-images --repository-name ${REPOSITORY_NAME} --region ${AWS_REGION} --output table

echo -e "${GREEN}🎯 Despliegue completado exitosamente!${NC}"
echo -e "${YELLOW}💡 Puedes usar esta URI en tus servicios de ECS, EKS, etc.${NC}"
