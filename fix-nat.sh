#!/bin/bash

# Скрипт автоматической настройки NAT для wg-easy (WireGuard)

set -e

# Определяем внешний интерфейс (который идёт в интернет)
EXT_IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
WG_SUBNET="10.42.42.0/24"

echo "🌐 Внешний интерфейс: $EXT_IFACE"
echo "🔧 Подсеть WireGuard: $WG_SUBNET"

# Проверяем, установлен ли nftables
if ! command -v nft >/dev/null 2>&1; then
  echo "📦 Устанавливаю nftables..."
  sudo apt update && sudo apt install nftables -y
fi

# Создаём или обновляем NAT-таблицу
sudo nft flush ruleset
sudo nft add table ip nat
sudo nft 'add chain ip nat postrouting { type nat hook postrouting priority 100; }'
sudo nft add rule ip nat postrouting oifname "$EXT_IFACE" ip saddr "$WG_SUBNET" masquerade

# Сохраняем правила
sudo mkdir -p /etc
sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null

# Включаем и перезапускаем nftables
sudo systemctl enable nftables
sudo systemctl restart nftables

echo "✅ NAT успешно настроен!"
sudo nft list ruleset | grep masquerade || echo "⚠️ Не найдено правил masquerade!"
