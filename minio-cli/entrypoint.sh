#!/bin/sh -l
set -euo pipefail

# --------------------------------------------------------------------------------
# SCRIPT DE ENTRYPOINT PARA ACTION MINIO CLI (v2 - Suporta arquivos e pastas)
# --------------------------------------------------------------------------------
# Este script detecta se a origem é um arquivo ou uma pasta e usa o comando
# 'mc cp' apropriado para fazer o upload para um bucket S3/Minio.
# --------------------------------------------------------------------------------

# 1. Configura o "alias" para o servidor Minio.
echo "Configurando alias 'deploy' para o endpoint Minio..."
mc alias set deploy "${MINIO_ENDPOINT}" "${MINIO_ACCESS_KEY}" "${MINIO_SECRET_KEY}" --api S3v4

# 2. Verifica se a origem especificada existe.
#    O 'if [ ! -e ... ]' checa se o caminho não existe.
if [ ! -e "${INPUT_SOURCE_DIR}" ]; then
  echo "Erro: A origem '${INPUT_SOURCE_DIR}' não foi encontrada!"
  exit 1
fi

# 3. Executa a cópia baseando-se no tipo da origem (arquivo ou pasta).
#    - 'if [ -d ... ]' verifica se a origem é um DIRETÓRIO.
#    - 'elif [ -f ... ]' verifica se a origem é um ARQUIVO.

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
