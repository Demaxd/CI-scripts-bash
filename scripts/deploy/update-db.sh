#!/usr/bin/env bash

# СКРИПТ ПРОИЗВОДИТ ОБНОВЛЕНИЕ КОНФИГУРАЦИИ БАЗЫ ДАННЫХ СОГЛАСНО ТЕКУЩЕЙ КОНФИГУРАЦИИ

# ========== ПОДКЛЮЧЕНИЕ ОБЩИХ ФУНКЦИЙ ==========
source "$CI_BUILD_ROOT/scripts/common/logging.sh" || exit 1
source "$CI_BUILD_ROOT/scripts/common/env-setup.sh" || exit 1

# СДЕЛАТЬ РЕФАКТ

update_db () {

    CONNECTION=$1
    DBUSER=$2
    DBPASSWORD=$3
    
    print_separator
    log_info "Обновление конфигурации БД"

    CMD="updatedb --ibconnection \"$CONNECTION\""

    if [ -n "$DBUSER" ]; then
        CMD+=" --db-user \"$DBUSER\""
    fi

    if [ -n "$DBPASSWORD" ]; then
        CMD+=" --db-pwd \"$DBPASSWORD\""
    fi

    if ! run_vrunner "$CMD"; then
        log_error "Не удалось обновить конфигурацию БД"
        return $?
    fi

    log_info "Конфигурация БД успешно обновлена"
    return 0

}