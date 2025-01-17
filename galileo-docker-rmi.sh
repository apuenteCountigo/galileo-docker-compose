#!/bin/bash

# Nombre del archivo que contiene los nombres de las imágenes
IMAGES_FILE="imagenes.txt"

# Leer cada línea del archivo y ejecutar docker save para cada imagen
while IFS= read -r IMAGE_NAME; do
    if [ -n "$IMAGE_NAME:1.1.4" ]; then
        docker rmi -f "${IMAGE_NAME}":1.1.4
    else
        echo "Línea vacía o nombre de imagen no válido, omitiendo..."
    fi
done < "$IMAGES_FILE"

echo "Todas las imágenes han sido eliminadas."