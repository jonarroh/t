#!/bin/bash

# Comprobar el tipo de versión
if [ "$1" != "minor" ] && [ "$1" != "major" ] && [ "$1" != "patch" ]; then
  echo "Uso: $0 {minor|major|patch}"
  exit 1
fi

# Pedir el nombre de la funcionalidad
read -p "Introduce el nombre de la funcionalidad: " FEATURE_NAME

# Ejecutar bumpversion (o npm version para actualizar la versión en package.json)
npm version $1 --no-git-tag-version

# Obtener la nueva versión del package.json
NEW_VERSION=$(jq -r '.version' package.json)

# Crear la rama según la convención
if [ "$1" == "minor" ]; then
  BRANCH_NAME="feature/v$NEW_VERSION"
elif [ "$1" == "major" ]; then
  BRANCH_NAME="release/v$NEW_VERSION"
elif [ "$1" == "patch" ]; then
  BRANCH_NAME="hotfix/v$NEW_VERSION"
fi

# Crear y cambiar a la nueva rama
git checkout -b "$BRANCH_NAME"

# Hacer el commit con el nombre de la funcionalidad
git add .
git commit -m "$1: $FEATURE_NAME"

# Hacer push de la nueva rama
git push origin "$BRANCH_NAME"
