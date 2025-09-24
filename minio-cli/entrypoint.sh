#!/bin/sh -l
set -euo pipefail

# Configura o alias para o servidor Minio.
echo "Configurando alias 'deploy' para o endpoint Minio..."
mc alias set deploy "${MINIO_ENDPOINT}" "${MINIO_ACCESS_KEY}" "${MINIO_SECRET_KEY}" --api S3v4

# Verifica se a origem especificada existe.
if [ ! -e "${INPUT_SOURCE_DIR}" ]; then
  echo "Erro: A origem '${INPUT_SOURCE_DIR}' não foi encontrada!"
  exit 1
fi

# Executa a cópia baseando-se no tipo da origem (arquivo ou pasta).
if [ -d "${INPUT_SOURCE_DIR}" ]; then
  # Se for um diretório, usa a flag '--recursive'.
  echo "A origem é um DIRETÓRIO. Usando cópia recursiva..."
  mc cp --overwrite --recursive \
    "${INPUT_SOURCE_DIR}" \
    "deploy/${INPUT_BUCKET}${INPUT_TARGET_DIR}"

elif [ -f "${INPUT_SOURCE_DIR}" ]; then
  # Se for um arquivo, faz a cópia simples.
  echo "A origem é um ARQUIVO. Usando cópia padrão..."
  mc cp --overwrite \
    "${INPUT_SOURCE_DIR}" \
    "deploy/${INPUT_BUCKET}${INPUT_TARGET_DIR}"

else
  # Se não for nem um arquivo comum nem um diretório, falha com erro.
  echo "Erro: A origem '${INPUT_SOURCE_DIR}' não é um arquivo ou diretório válido."
  exit 1
fi

echo "Operação concluída com sucesso!"
