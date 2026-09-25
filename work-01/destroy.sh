#!/bin/bash

# Если случается ошибка то ливаем отсюда
set -e

# Дефолтные значения
PREFIX="chavykin-06"
ZONE="ru-central1-d"

show_help() {
    echo " --prefix Префикс для имени ВМ и подсети"
    echo " --zone Зона Yandex Cloude"
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

echo "Удаление машин $VM_NAME1 и $VM_NAME2..."

yc compute instance delete --name "$VM_NAME1"

echo "$VM_NAME1 удалена"

yc compute instance delete --name "$VM_NAME2"

echo "$VM_NAME2 удалена"

echo "Удаление подсети $SUBNET_NAME"

yc vpc subnet delete --name "$SUBNET_NAME"

echo "$SUBNET_NAME успешно удалена."

echo "Удаление сети $NETWORK_NAME"

yc vpc network delete --name "$NETWORK_NAME"

echo "$NETWORK_NAME успешно удалена."

echo "Убедиться в успешном удалении машин можно выполнив команды: yc compute instance list && yc vpc network list && yc compute disk list"