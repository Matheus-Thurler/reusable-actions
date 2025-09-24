#!/bin/sh -l
set -euo pipefail

# Configura o alias para o Minio usando as variáveis de ambiente padrão
mc alias set deploy "${MINIO_ENDPOINT}" "${MINIO_ACCESS_KEY}" "${MINIO_SECRET_KEY}" --api S3v4

# Copia o arquivo usando as variáveis de ambiente injetadas pelo GitHub Actions.
# Isso é muito mais confiável do que usar os argumentos $1 e $2.
# A variável ${INPUT_SOURCE_DIR} virá diretamente do seu "with: source_dir:"
mc cp "${INPUT_SOURCE_DIR}" "deploy/${INPUT_BUCKET}${INPUT_TARGET_DIR}"
