#!/bin/bash

# Comprobar el tipo de versión
if [ "$1" != "minor" ] && [ "$1" != "major" ] && [ "$1" != "patch" ]; then
  echo "Uso: $0 {minor|major|patch}"
  exit 1
fi

# Pedir el nombre de la funcionalidad
read -p "Introduce el nombre de la funcionalidad: " FEATURE_NAME

# Ejecutar bumpversion
bumpversion $1

# Obtener la nueva versión
NEW_VERSION=$(python -c "import re; f=open('setup.py'); print(re.search(r'version=\'([^\']+)', f.read()).group(1)); f.close()")

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

# Generar changelog
./generate_changelog.sh

# Hacer push de la nueva rama
git push origin "$BRANCH_NAME"
