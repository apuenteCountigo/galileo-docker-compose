#!/bin/bash

# Nombre del archivo que contiene los nombres de las imágenes
IMAGES_FILE="imagenes.txt"
# Carpeta de destino para guardar las imágenes
DEST_DIR="/home/mome/galileo-images-v1.1.0"

# Crear la carpeta de destino si no existe
mkdir -p "$DEST_DIR"

# Leer cada línea del archivo y ejecutar docker save para cada imagen
while IFS= read -r IMAGE_NAME; do
    if [ -n "$IMAGE_NAME" ]; then
        OUTPUT_FILE="${DEST_DIR}/${IMAGE_NAME}_1.1.0.tar"
        echo "Guardando la imagen '$IMAGE_NAME':1.1.0 en '$OUTPUT_FILE'..."
        docker save -o "$OUTPUT_FILE" "${IMAGE_NAME}:1.1.0"
    else
        echo "Línea vacía o nombre de imagen no válido, omitiendo..."
    fi
done < "$IMAGES_FILE"

echo "Todas las imágenes han sido guardadas en la carpeta '$DEST_DIR'."