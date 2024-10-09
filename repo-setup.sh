#!/bin/bash
set -x

# Configuraciones iniciales
GITEA_URL="http://galileo-git:3080"
GITEA="galileo-git:3080"
USERNAME="galileo_user"
PASSWORD="Galileo.12345"
ORG_NAME="galileo"
REPO_NAME="galileo-config"

# Esperar a que Gitea esté completamente operativo
max_retries=30
counter=0
while [ $counter -lt $max_retries ]; do
    if curl -s -f -u $USERNAME:$PASSWORD $GITEA_URL/api/v1/version; then
        echo "Gitea está en funcionamiento"
        break
    fi
    echo "Esperando a que Gitea esté listo..."
    sleep 10
    counter=$((counter + 1))
done

if [ $counter -eq $max_retries ]; then
    echo "Gitea no se puso en marcha a tiempo"
    exit 1
fi

# Verificar si la organización ya existe
ORG_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" -u $USERNAME:$PASSWORD \
$GITEA_URL/api/v1/orgs/$ORG_NAME)

if [ "$ORG_EXISTS" -eq 404 ]; then
    echo "Creando organización $ORG_NAME..."
    curl -X POST "$GITEA_URL/api/v1/orgs" \
         -H "Content-Type: application/json" \
         -u $USERNAME:$PASSWORD \
         -d "{\"username\": \"$ORG_NAME\", \"visibility\": \"public\"}"
else
    echo "La organización $ORG_NAME ya existe, omitiendo creación."
fi

# Verificar si el repositorio ya existe en la organización
REPO_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" -u $USERNAME:$PASSWORD \
$GITEA_URL/api/v1/repos/$ORG_NAME/$REPO_NAME)

if [ "$REPO_EXISTS" -eq 404 ]; then
    echo "Creando repositorio $REPO_NAME en la organización $ORG_NAME..."
    curl -X POST "$GITEA_URL/api/v1/org/$ORG_NAME/repos" \
         -H "Content-Type: application/json" \
         -u $USERNAME:$PASSWORD \
         -d "{\"name\": \"$REPO_NAME\", \"private\": false, \"default_branch\": \"main\"}" &&

    cd data
    mkdir properties
    cd properties
    # Clonar el repositorio en el directorio actual
    git clone http://$USERNAME:$PASSWORD@$GITEA/$ORG_NAME/$REPO_NAME.git .

    # Configurar el usuario de Git
    git config --global user.email "$USERNAME@example.com"
    git config --global user.name "$USERNAME"

    # Crear y cambiar a la rama 'main'
    git checkout -b main

    # Copiar los archivos al repositorio
    cp -r /repo-files/* .

    # Agregar y hacer commit de los archivos
    git add .
    git commit -m "Initial commit"

    # Hacer push al repositorio remoto
    git push -u origin main
else
    echo "El repositorio $REPO_NAME ya existe en la organización $ORG_NAME, omitiendo creación."
fi