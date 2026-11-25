#!/usr/bin/env bash

# ========== ПОДКЛЮЧЕНИЕ ОБЩИХ ФУНКЦИЙ ==========
source "$CI_BUILD_ROOT/scripts/common/logging.sh" || exit 1
source "$CI_BUILD_ROOT/scripts/common/config-reader.sh" || exit 1

# Исполняемые файлы утилит
# EDT_CLI="1cedtcli.exe"
# VRUNNER="vrunner.bat"
# PLATFORM="E:/Software/Platform/8.3.27.2130/bin/1cv8.exe"

PLATFORM="$(read_config_variable '.environment.v8_path')"
VRUNNER="$(read_config_variable '.environment.vrunner_path')"
EDT_CLI="$(read_config_variable '.environment.edt_cli_path')"


# Проверка наличия утилиты
check_command() {
    if ! command -v "$1" &>/dev/null; then
        log_error "Утилита '$1' не найдена. Пожалуйста, установите её."
        return 1
    fi
    return 0
}

# Запуск vrunner с произвольными параметрами
run_vrunner() {
    local args="$*"
    run_cmd "$VRUNNER $args"
    return $?
}

# Запуск 1cedtcli с произвольными параметрами
run_cli() {
    local args="$*"
    run_cmd "$EDT_CLI $args"
    return $?
}

run_1c() {
    # Передаём все аргументы функции как отдельные параметры команды
    run_cmd_array "$PLATFORM" "$@"
    return $?
}

# Безопасный запуск команды: логирует, выполняет, при ошибке не завершает весь скрипт
run_cmd() {
    local cmd="$*"
    log_info "Выполнение: $cmd"
    eval "$cmd" 2>&1 | tee -a "$LOG_FILE"
    local ret=${PIPESTATUS[0]}
    if [ $ret -ne 0 ]; then
        log_error "Команда завершилась с кодом $ret: $cmd"
    fi
    return $ret
}

# Запуск команды с передачей аргументов в виде массива
run_cmd_array() {
    local args=("$@")                     # все аргументы в массиве
    local cmd="${args[*]}"                # для логирования – склеиваем через пробел
    log_info "Выполнение: $cmd"
    # Выполняем команду напрямую, без eval
    "${args[@]}" 2>&1 | tee -a "$LOG_FILE"
    local ret=${PIPESTATUS[0]}
    if [ $ret -ne 0 ]; then
        log_error "Команда завершилась с кодом $ret: $cmd"
    fi
    return $ret
}