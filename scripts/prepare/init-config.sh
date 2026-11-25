#!/usr/bin/env bash

# ПРОВЕРЯЕТ НАЛИЧИЕ КОНФИГА ПАЙПЛАЙНА, ИНИЦИАЛИЗИРУЕТ ОБЯЗАТЕЛЬНУЮ ГЛОБАЛЬНУЮ ПЕРЕМЕННУЮ: КОРЕНЬ КАТАЛОГА СБОРКИ

#cd "$CI_BUILD_ROOT"

# Находит корень CI, поднимаясь вверх от указанного каталога в поисках файла-маркера.
# Аргументы:
#   $1 - стартовый каталог (по умолчанию - текущая директория)
# Возвращает:
#   0 - корень найден, путь выводится в stdout
#   1 - корень не найден
find_ci_root() {
    local start_dir="${1:-$(pwd)}"
    # Приводим к абсолютному пути и нормализуем
    start_dir="$(cd "$start_dir" && pwd)"
    local dir="$start_dir"

    while [ "$dir" != "/" ]; do
        if [ -f "$dir/$CI_ROOT_MARKER" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    # Проверим корневую папку файловой системы (на случай, если маркер прямо в /)
    if [ -f "/$CI_ROOT_MARKER" ]; then
        echo "/"
        return 0
    fi

    return 1
}

# Поиск корневого каталога

printf "Поиск корневого каталога CI...\n"

CI_ROOT_MARKER="${CI_ROOT_MARKER:-.ci-root}"

# ---------- Определение корня проекта ----------
if [ -z "${CI_BUILD_ROOT:-}" ]; then
    # 1. Пробуем через переменную окружения (если задана извне)
    if [ -n "${CI_BUILD_ROOT}" ]; then
        export CI_BUILD_ROOT
    # 2. Ищем, отталкиваясь от каталога, где лежит этот скрипт
    elif root="$(find_ci_root "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"; then
        export CI_BUILD_ROOT="$root"
    # 3. Последняя попытка – от текущей рабочей директории
    elif root="$(find_ci_root "$(pwd)")"; then
        export CI_BUILD_ROOT="$root"
    else
        printf "ОШИБКА: Не удалось найти корень CI. Создайте маркерный файл '$CI_ROOT_MARKER' в корне проекта." >&2
        exit 1
    fi
fi

printf "Корневой каталог CI обнаружен: $CI_BUILD_ROOT\n"

# ========== ПОДКЛЮЧЕНИЕ ФУНКЦИЙ ЛОГИРОВАНИЯ ==========
source "$CI_BUILD_ROOT/scripts/common/logging.sh" || exit 1

# Проверяем наличие файла конфигурации

log_info "Поиск файла конфига CI..."

PIPELINE_CONFIG="$CI_BUILD_ROOT/config/pipeline_config.json"
if [ ! -f "$PIPELINE_CONFIG" ]; then
    log_error "Файл конфигурации '$PIPELINE_CONFIG' не найден."
    exit 1
fi

log_info "Файл конфига CI обнаружен: $PIPELINE_CONFIG"



exit 0