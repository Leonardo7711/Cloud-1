#!/usr/bin/env bash

set -euo pipefail

SERVIDORES=(
  "137.131.3.122 nginx.key"
  "137.131.23.120 nginx2.key"
  "158.101.19.118 nginx-php.key"
)

USUARIO="ubuntu"
DESTINO="/var/www/html/agenda"

cd "$(dirname "$0")"

for entrada in "${SERVIDORES[@]}"; do
  read -r ip llave <<< "$entrada"

  echo ">>> Sincronizando con $ip (llave: $llave) ..."

  tar --exclude='.git*' \
      --exclude='database' \
      --exclude='deploy.sh' \
      --exclude='README.md' \
      -czf - . \
    | ssh -i "$HOME/.ssh/$llave" \
      -o StrictHostKeyChecking=accept-new \
      "$USUARIO@$ip" \
      "find $DESTINO -mindepth 1 -delete && \
       tar -xzf - -C $DESTINO && \
       find $DESTINO -type d -exec chmod 755 {} + && \
       find $DESTINO -type f -exec chmod 644 {} +"

  echo "    OK: $ip"
done

echo "Despliegue terminado en ${#SERVIDORES[@]} servidores."
