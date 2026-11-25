#!/usr/bin/env bash


# ========== ИНИЦИАЛИЗАЦИЯ ==========

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



# ========== ПОДКЛЮЧЕНИЕ ОБЩИХ ФУНКЦИЙ ==========

SCRIPTS_PATH="$CI_BUILD_ROOT/scripts"

source "$SCRIPTS_PATH/common/config-reader.sh" || exit 1
source "$SCRIPTS_PATH/common/logging.sh" || exit 1
source "$SCRIPTS_PATH/build/git-repo-downloader.sh" || exit 1
source "$SCRIPTS_PATH/build/cf-unload.sh" || exit 1
#source "$SCRIPTS_PATH/build/cf-load.sh" || exit 1
# source "$SCRIPTS_PATH/build/update-db.sh" || exit 1
# source "$SCRIPTS_PATH/build/cluster.sh" || exit 1

# ========== ЧТЕНИЕ КОНФИГУРАЦИОННОГО JSON ==========
if ! check_config_file; then
    exit 1
fi


"$SCRIPTS_PATH/stages/build.sh"
"$SCRIPTS_PATH/stages/deploy.sh"


# if ! download_extensions; then
#     exit 1
# fi

# if ! upload_cf; then
#     exit 1
# fi




# CONFIG_FILE="config/extensions.sh"

# SUCCESSFUL_EXTS=()
# FAILED_EXTS=()


# log_info "=========================================="
# log_info "Запуск пайплайна CI_Build"


# # Загружаем конфигурацию (ожидаем строки вида EXT_NAME=URL)
# declare -A EXT_REPOS
# while IFS='=' read -r name url || [[ -n "$name" ]]; do
#     # Удаляем \r (Windows CR) – основная причина проблем
#     name="${name%$'\r'}"
#     url="${url%$'\r'}"

#     # Пропускаем пустые строки и комментарии
#     [[ -z "$name" || "$name" =~ ^# ]] && continue

#     # Пропускаем строки, где нет URL (на всякий случай)
#     [[ -z "$url" ]] && continue

#     # Убираем все обрамляющие кавычки (одинарные и двойные)
#     url="${url//\"/}"
#     url="${url//\'/}"

#     # Убираем возможные пробелы в начале и конце (если есть)
#     name="$(echo "$name" | xargs)"s
#     url="$(echo "$url" | xargs)"

#     EXT_REPOS["$name"]="$url"
#     log_info "Добавлено расширение: $name <- $url"   # необязательно, для отладки
# done < "$CONFIG_FILE"

# if [ ${#EXT_REPOS[@]} -eq 0 ]; then
#     log_error "В файле конфигурации не задано ни одного расширения."
#     exit 1
# fi

# log_info "Найдено расширений: ${#EXT_REPOS[@]}"


# # ---------- Шаг 1: Клонирование всех репозиториев ----------
# log_info "=== Этап: Клонирование репозиториев ==="
# for EXT_NAME in "${!EXT_REPOS[@]}"; do
#     REPO_URL="${EXT_REPOS[$EXT_NAME]}"
#     if ! "${CI_BUILD_ROOT}/scripts/prepare/git-clone.sh" "$REPO_URL" "$EXT_NAME"; then
#         FAILED_EXTS+=("$EXT_NAME")
#         log_error "Расширение '$EXT_NAME' не будет собрано из-за ошибки клонирования."
#     fi
# done

# # ---------- Шаг 2: Сборка cfe-файлов ----------
# log_info "=== Этап: Сборка расширений ==="
# for EXT_NAME in "${!EXT_REPOS[@]}"; do
#     # Пропускаем расширения, которые уже провалились на клонировании
#     if [[ " ${FAILED_EXTS[*]} " =~ " ${EXT_NAME} " ]]; then
#         log_warn "Пропуск сборки для '$EXT_NAME' – ошибка на предыдущем этапе."
#         continue
#     fi
#     if ! "${CI_BUILD_ROOT}/scripts/build/cfe-edt-builder.sh" "$EXT_NAME"; then
#         FAILED_EXTS+=("$EXT_NAME")
#     else
#         SUCCESSFUL_EXTS+=("$EXT_NAME")
#     fi
# done


# # ---------- Итоги по расширениям ----------
# if [ ${#FAILED_EXTS[@]} -gt 0 ]; then
#     log_error "Следующие расширения не были успешно обработаны: ${FAILED_EXTS[*]}"
#     exit 1
# else
#     log_info "Все расширения успешно обработаны!"
# fi

# # ---------- Шаг 3: Выгрузка основной конфигурации ----------
# log_info "=== Этап: Выгрузка основной конфигурации ==="
# if ! "${CI_BUILD_ROOT}/scripts/build/cf-unload.sh"; then
#      log_error "Не удалось выгрузить CF основной конфигурации"
#      exit 1
# fi


# # ---------- Шаг 4 Загрузка основной конфигурации ----------
# log_info "=== Этап: Загрузка основной конфигурации ==="
# if ! load_cf "config.cf" "/FE:\1C\DB\File\83Demo_CI_receiver" "Администратор"; then
#     exit 1
# fi

# # ---------- Шаг 5 Загрузка расширений ----------
# log_info "=== Этап: Загрузка расширений ==="

# for EXT_NAME in "${SUCCESSFUL_EXTS[@]}"; do
#     if ! load_cfe "$EXT_NAME" "/FE:\1C\DB\File\83Demo_CI_receiver" "Администратор"; then
#         log_error "Не удалось загрузить расширение $EXT_NAME в ИБ"
#     fi
# done

# # # ---------- Шаг 6 Обновление конфигурации БД ----------
#  log_info "=== Этап: Обновление конфигурации БД  ==="

# if ! update_db "/FE:\1C\DB\File\83Demo_CI_receiver" "Администратор"; then
#     exit 1
# fi


# # ---------- Блокировка сеансов пользователей ----------
#  log_info "=== Этап: Блокировка сеансов пользователей  ==="

# if ! lock_sessions "Demo83" "Администратор"; then
#     exit 1
# fi

# # ---------- Разблокировка сеансов пользователей ----------
#  log_info "=== Этап: Разблокировка сеансов пользователей ==="

# if ! unlock_sessions "Demo83" "Администратор"; then
#     exit 1
# fi

# # ---------- Завершение сеансов пользователей ----------
#  log_info "=== Этап: Завершение сеансов пользователей ==="

# if ! kill_sessions "Demo83" "Администратор"; then
#     exit 1
# fi

# # ---------- Блокировка регламентных заданий ----------
#  log_info "=== Этап: Блокировка регламентных заданий ==="

# if ! lock_jobs "Demo83" "Администратор"; then
#     exit 1
# fi


# # ---------- Разблокировка регламентных заданий ----------
#  log_info "=== Этап: Разблокировка регламентных заданий ==="

# if ! unlock_jobs "Demo83" "Администратор"; then
#     exit 1
# fi






  exit 0