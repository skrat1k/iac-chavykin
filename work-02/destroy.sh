#!/usr/bin/env bash
set -euo pipefail            # стоп на первой ошибке и на пустой переменной

PREFIX=chavykin-06            # у вас — свои значения из варианта

show_help() {
    echo " --prefix Префикс созданных элементов"
    echo " --help Справка"
}

# Получение параметров
while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)
            PREFIX="$2"
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

## проходимся по всем балансировщикам, если в имени есть подстрока с префиксом - удаляем. Если нет, то ниче не делаем соответственно
while read -r id name; do
  if [[ "$name" == *"$PREFIX"* ]]; then
    
    yc load-balancer network-load-balancer delete "$id"

  fi
done < <(yc load-balancer network-load-balancer list --format json | jq -r '.[] | "\(.id) \(.name)"' 2>/dev/null || true)

## проходимся по всем таргет-группам, если в имени есть подстрока с префиксом - удаляем. Если нет, то ниче не делаем соответственно
while read -r id name; do
  if [[ "$name" == *"$PREFIX"* ]]; then

    yc load-balancer target-group delete "$id"

  fi
done < <(yc load-balancer target-group list --format json | jq -r '.[] | "\(.id) \(.name)"' 2>/dev/null || true)

## проходимся по всем инстансам, если в имени есть подстрока с префиксом - удаляем. Если нет, то ниче не делаем соответственно
while read -r id name; do
  if [[ "$name" == *"$PREFIX"* ]]; then

    yc compute instance delete "$id"

  fi
done < <(yc compute instance list --format json | jq -r '.[] | "\(.id) \(.name)"' 2>/dev/null || true)

while read -r id name; do
  if [[ "$name" == *"$PREFIX"* ]]; then

    yc compute disk delete "$id"

  fi
done < <(yc compute disk list --format json | jq -r '.[] | "\(.id) \(.name)"' 2>/dev/null || true)

while read -r id name; do
  if [[ "$name" == *"$PREFIX"* ]]; then

    yc vpc subnet delete "$id"

  fi
done < <(yc vpc subnet list --format json | jq -r '.[] | "\(.id) \(.name)"' 2>/dev/null || true)


while read -r id name; do
  if [[ "$name" == *"$PREFIX"* ]]; then

    yc vpc network delete "$id"

  fi
done < <(yc vpc network list --format json | jq -r '.[] | "\(.id) \(.name)"' 2>/dev/null || true)
