#!/bin/bash

# Если случается ошибка то ливаем отсюда
set -e

# Дефолтные значения
PREFIX="chavykin-06"
ZONE="ru-central1-d"
CIDR="10.16.1.0/24"
DISK_SIZE="25"

show_help() {
    echo " --prefix Префикс для имени ВМ и подсети"
    echo " --zone Зона Yandex Cloude"
    echo " --size Размер диска"
    echo " --help Справка"
}

# Получение параметров
while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --zone)
            ZONE="$2"
            shift 2
            ;;
        --size)
            DISK_SIZE="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Неизвестный параметр $1"
            echo "Используйте $0 --help чтобы узнать доступные параметры"
            exit 1
            ;;
    esac
done

NETWORK_NAME="$PREFIX-net"
SUBNET_NAME="$PREFIX-subnet"

VM_NAME1="$PREFIX-app-1"
VM_NAME2="$PREFIX-app-2"

SSH_PUB_KEY="$HOME/.ssh/id_ed25519.pub"

if [ ! -f "$SSH_PUB_KEY" ]; then
    echo "Не найден ssh-key: $SSH_PUB_KEY"
    exit 1
fi

yc vpc network create --name "$NETWORK_NAME"

yc vpc subnet create --name "$SUBNET_NAME" --network-name "$NETWORK_NAME" --zone "$ZONE" --range "$CIDR"

echo "СОЗДАНИЕ МАШИНЫ С КОНФИГУРАЦИЕЙ:"
echo -e "Name: $VM_NAME1\nZone: $ZONE\nDISK_SIZE: $DISK_SIZE gb"
echo "Пожалуйста, подождите..."

yc compute instance create \
    --name "$VM_NAME1" \
    --hostname "$VM_NAME1" \
    --zone "$ZONE" \
    --platform standard-v3 \
    --cores=2 \
    --core-fraction=20 \
    --memory=2 \
    --preemptible \
    --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2404-lts,type=network-hdd,size="$DISK_SIZE" \
    --network-interface subnet-name="$SUBNET_NAME",nat-ip-version=ipv4 \
    --ssh-key "$SSH_PUB_KEY" \
    --labels created-by=cli

echo "Машина готова."
echo "Вы можете подключиться к машине по команде ssh yc-user@$(yc compute instance get "$VM_NAME1" --format json \
                                                                | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')"

echo "СОЗДАНИЕ МАШИНЫ С КОНФИГУРАЦИЕЙ:"
echo -e "Name: $VM_NAME2\nZone: $ZONE\nDISK_SIZE: $DISK_SIZE gb"
echo "Пожалуйста, подождите..."

yc compute instance create \
    --name "$VM_NAME2" \
    --hostname "$VM_NAME2" \
    --zone "$ZONE" \
    --platform standard-v3 \
    --cores=2 \
    --core-fraction=20 \
    --memory=2 \
    --preemptible \
    --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2404-lts,type=network-hdd,size="$DISK_SIZE" \
    --network-interface subnet-name="$SUBNET_NAME",nat-ip-version=ipv4 \
    --ssh-key "$SSH_PUB_KEY" \
    --labels created-by=cli

echo "Машина готова."
echo "Вы можете подключиться к машине по команде ssh yc-user@$(yc compute instance get "$VM_NAME2" --format json \
                                                                | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')"
