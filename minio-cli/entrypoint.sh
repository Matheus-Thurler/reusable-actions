#!/bin/sh -l
set -euo pipefail


echo ""

echo "--> 2. O que tem aqui? (Listando arquivos no diretório atual)"
ls -lahR
echo ""

echo "--> 3. Quais são as variáveis de input da action?"
echo "    INPUT_ENDPOINT: '${INPUT_ENDPOINT}'"
echo "    INPUT_ACCESS_KEY: '*****' (Oculto por segurança)"
echo "    INPUT_SECRET_KEY: '*****' (Oculto por segurança)"
echo "    INPUT_BUCKET: '${INPUT_BUCKET}'"
echo "    INPUT_SOURCE_DIR: '${INPUT_SOURCE_DIR}'"
echo "    INPUT_TARGET_DIR: '${INPUT_TARGET_DIR}'"
echo ""

echo "--> 4. Verificando a existência do arquivo/pasta de origem..."
# Vamos testar o caminho exato que o script usa
if [ -e "${INPUT_SOURCE_DIR}" ]; then
  echo "    SUCESSO: O caminho '${INPUT_SOURCE_DIR}' foi encontrado!"
else
  echo "    FALHA: O caminho '${INPUT_SOURCE_DIR}' NÃO foi encontrado a partir de $(pwd)."
fi

echo ""
echo "================ FIM DO DIAGNÓSTICO ================"
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
