#!/usr/bin/env bash

# СКРИПТ ПРОИЗВОДИТ ЗАГРУЗКУ CF/CFE ФАЙЛОВ В ИНФОРМАЦИОННУЮ БАЗУ

# ========== ПОДКЛЮЧЕНИЕ ОБЩИХ ФУНКЦИЙ ==========
source "$CI_BUILD_ROOT/scripts/common/logging.sh" || exit 1
source "$CI_BUILD_ROOT/scripts/common/env-setup.sh" || exit 1
source "$CI_BUILD_ROOT/scripts/common/config-reader.sh" || exit 1

DBUSER="$(read_config_variable '.cluster.user')"
DBPASSWORD="$(read_config_variable '.cluster.password')"
CONNECTION="$(read_config_variable '.cf_source.connection_string')"
UPDATE_FROM_CF="$(read_config_variable '.cf_receiver.update_from_cf')"

CF_DIR="$CI_BUILD_ROOT/$(read_config_variable '.directories.build_cf')"
CFE_DIR="$CI_BUILD_ROOT/$(read_config_variable '.directories.build_cfe')"

load_cf() {

    CF_FILE="$(read_config_variable '.cf_source.name')"
    CF_PATH="$CF_DIR/$CF_FILE.cf"

    print_separator
    log_info "Импорт CF-файла в ИБ"

    if [ "$UPDATE_FROM_CF" = "false" ]; then
        log_info "Обновление основной конфигурации из файла отключено, шаг выгрузки CF пропущен"
        return 0;
    fi

    if ! [ -e "$CF_PATH" ]; then
        log_error "Файл '$CF_PATH' не обнаружен"
        return 1
    fi

    log_info "Загрузка файла $CF_PATH в $CONNECTION..."

    CMD="load --src $CF_PATH --ibconnection $CONNECTION"
    
    if [ -n "$DBUSER" ]; then
        CMD+=" --db-user \"$DBUSER\""
    fi

    if [ -n "$DBPASSWORD" ]; then
        CMD+=" --db-pwd \"$DBPASSWORD\""
    fi

    if ! run_vrunner "$CMD"; then
        log_error "Не удалось загрузить CF-файл в ИБ"
        return $?
    fi

    log_info "Файл $CF_PATH успешно загружен в $CONNECTION (без обновления БД)"
    return 0

}

load_cfe() {


    EXT_NAME=$1
    CFE_FILE="$CFE_DIR/$EXT_NAME.cfe"

    print_separator
    log_info "Импорт расширения $CFE_FILE в ИБ $CONNECTION"

    CMD="loadext --file $CFE_FILE --ibconnection \"$CONNECTION\" --extension $EXT_NAME"
    if [ -n "$3" ]; then
        CMD+=" --db-user \"$3\""
    fi

    if [ -n "$4" ]; then
        CMD+=" --db-pwd \"$4\""
    fi

    if ! run_vrunner "$CMD"; then
        log_error "Не удалось импортировать CFE-файл $CFE_FILE в ИБ"
        return $?
    fi

    log_info "Расширение $CFE_FILE успешно загружено в ИБ $CONNECTION (без обновления БД)"
    return 0

}

load_cfes() {

    print_separator
    log_info "Импорт расширений в ИБ"

    EXTS_JSON="$(read_config_fragment '.extensions')"
    
    while IFS= read -r ext_json; do
        local EXT_NAME="$(echo "$ext_json" | jq -r '.name')"

        log_info "Обработка расширения: $EXT_NAME"

        if ! load_cfe "$EXT_NAME"; then
            return $?
        fi

    done < <(echo "$EXTS_JSON" | jq -c '.[]')

    return 0

}