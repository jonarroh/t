#!/bin/bash

# Comprobar el tipo de versión o la opción de commit
if [ "$1" != "minor" ] && [ "$1" != "major" ] && [ "$1" != "patch" ] && [ "$1" != "commit" ]; then
  echo "Uso: $0 {minor|major|patch|commit}"
  exit 1
fi

# Pedir el nombre de la funcionalidad si no es commit
if [ "$1" != "commit" ]; then
  read -p "Introduce el nombre de la funcionalidad: " FEATURE_NAME
fi

# Obtener la rama actual
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Evitar subir cambios directamente a main o develop si es commit
if [ "$1" == "commit" ]; then
  if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "develop" ]]; then
    echo "No se pueden subir cambios directamente a main o develop. Cambia a otra rama."
    exit 1
  else
    echo "Subiendo cambios a la rama actual: $CURRENT_BRANCH"
    git add .
    git commit -m "WIP: cambios nuevos en $CURRENT_BRANCH"
    git push origin "$CURRENT_BRANCH"
    exit 0
  fi
fi

# Si no es commit, seguir con el proceso de bumpversion
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

# Generar changelog (asegúrate de que este script existe y está configurado)
./generate_changelog.sh

# Hacer push de la nueva rama
git push origin "$BRANCH_NAME"
