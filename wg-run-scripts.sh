#!/bin/bash

# Проверяем, существует ли сеть wg — если нет, создаём
if ! docker network ls | grep -q "wg"; then
  echo "Создаю сеть wg..."
  docker network create --subnet=10.42.42.0/24 --ipv6 --subnet=fdcc:ad94:bacf:61a3::/64 wg
fi

echo "Запускаю контейнер wg-easy..."

docker run -d \
  --net wg \
  -e INSECURE=true \
  --name wg-easy \
  --ip6 fdcc:ad94:bacf:61a3::2a \
  --ip 10.42.42.42 \
  -v ~/.wg-easy:/etc/wireguard \
  -v /lib/modules:/lib/modules:ro \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  --sysctl net.ipv4.ip_forward=1 \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \
  --sysctl net.ipv6.conf.all.disable_ipv6=0 \
  --sysctl net.ipv6.conf.all.forwarding=1 \
  --sysctl net.ipv6.conf.default.forwarding=1 \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy:15

echo "✅ Контейнер wg-easy запущен."
