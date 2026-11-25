#!/usr/bin/env bash

# перед вызовом скрипта должна быть инициализирована CI_BUILD_ROOT
# ========== ПОДКЛЮЧЕНИЕ ФУНКЦИЙ ЛОГИРОВАНИЯ ==========
source "$CI_BUILD_ROOT/scripts/common/logging.sh" || exit 1

PIPELINE_CONFIG="$CI_BUILD_ROOT/config/pipeline_config.json"


check_config_file() {

    log_info "Поиск файла конфигуации CI..."

    if [ ! -f "$PIPELINE_CONFIG" ]; then
        log_error "Файл конфигурации '$PIPELINE_CONFIG' не найден."
        return 1
    fi

    log_info "Файл конфига CI обнаружен: $PIPELINE_CONFIG"
    return 0

}


# ЧТЕНИЕ КОНФИГА В ПЕРЕМЕННЫЕ

# Читает значение из JSON-файла по указанному пути (в формате jq).
# Аргументы:
#   $1 - JSON-путь (например, '.environment.v8_path')
#   $2 - значение по умолчанию (если не задано, используется пустая строка)
# Файл конфигурации берётся из переменной PIPELINE_CONFIG (должна быть определена до вызова).
read_config_variable() {
    local path="$1"
    local default="${2:-}"

    # Если default не задан, jq вернёт null; оператор // заменит null на default.
    # Кавычки вокруг default защищают от разбиения, если в нём есть пробелы.
    jq -r "$path // \"$default\"" "$PIPELINE_CONFIG"
}


# Читает фрагмент JSON из конфигурации и возвращает его как сжатый JSON.
# Аргументы:
#   $1 - jq-путь к массиву или объекту (например, '.extensions')
#
#Обход по элементам делать так:
# while IFS= read -r ext_json; do
#     name="$(echo "$ext_json" | jq -r '.name')"
#     url="$(echo "$ext_json" | jq -r '.repo_url')"
#     # другие поля при необходимости: enabled="$(echo "$ext_json" | jq -r '.enabled')"
# done
read_config_fragment() {
    local path="$1"
    jq -c "$path // []" "$PIPELINE_CONFIG"
}