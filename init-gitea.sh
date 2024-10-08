#!/bin/bash
set -e

# Esperar a que Gitea esté listo
until curl -s http://galileo-git:3080/api/v1/version; do
    echo "Esperando a que Gitea esté listo..."
    # Obtener y mostrar el código de estado HTTP
    HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://galileo-git:3080/api/v1/version)
    echo "Código de estado HTTP: $HTTP_STATUS"
    # Obtener y mostrar la respuesta completa
    RESPONSE=$(curl -s http://galileo-git:3080/api/v1/version)
    echo "Respuesta: $RESPONSE"
    sleep 10
done

echo "Gitea está listo."

# Verificar si el usuario ya existe
if /app/gitea/gitea admin user list | grep -q "galileo_user"; then
    echo "El usuario galileo_user ya existe."
else
    echo "Creando usuario galileo_user..."
    /app/gitea/gitea admin user create --admin --username galileo_user --password Galileo.12345 --email galileo_user@example.com
    echo "Usuario galileo_user creado con éxito."
fi