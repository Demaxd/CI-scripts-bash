#!/usr/bin/env bash

# СКРИПТ ПРОИЗВОДИТ РАБОТУ С КЛАСТЕРОМ СЕРВЕРОВ 1С (УПРАВЛЕНИЕ СЕАНСАМИ И РЕГЛАМЕНТНЫМИ ЗАДАНИЯМИ) 

# ========== ПОДКЛЮЧЕНИЕ ОБЩИХ ФУНКЦИЙ ==========
source "$CI_BUILD_ROOT/scripts/common/logging.sh" || exit 1
source "$CI_BUILD_ROOT/scripts/common/env-setup.sh" || exit 1

RAS_HOST="localhost"

lock_sessions() {

    DBNAME=$1
    DBUSER=$2
    DBPASSWORD=$3

    log_info "Начало блокировки сеансов пользователей (lock_sessions)"

    CMD="session lock --ras $RAS_HOST --db $DBNAME"

    if [ -n "$DBUSER" ]; then
        CMD+=" --db-user \"$DBUSER\""
    fi

    if [ -n "$DBPASSWORD" ]; then
        CMD+=" --db-pwd \"$DBPASSWORD\""
    fi

    if ! run_vrunner "$CMD"; then
        log_error "Не удалось выполнить блокировку сеансов (lock_sessions)"
        return $?
    fi

    log_info "Блокировка сеансов успешно выполнена"
    return 0

}

unlock_sessions() {

    DBNAME=$1
    DBUSER=$2
    DBPASSWORD=$3

    log_info "Начало разблокировки сеансов пользователей (unlock_sessions)"

    CMD="session unlock --ras $RAS_HOST --db $DBNAME"

    if [ -n "$DBUSER" ]; then
        CMD+=" --db-user \"$DBUSER\""
    fi

    if [ -n "$DBPASSWORD" ]; then
        CMD+=" --db-pwd \"$DBPASSWORD\""
    fi

    if ! run_vrunner "$CMD"; then
        log_error "Не удалось выполнить разблокировку сеансов (unlock_sessions)"
        return $?
    fi

    log_info "Разблокировка сеансов успешно выполнена"
    return 0

}


kill_sessions() {

    DBNAME=$1
    DBUSER=$2
    DBPASSWORD=$3

    log_info "Завершение сеансов всех пользователей (kill_sessions)"

    CMD="session kill --ras $RAS_HOST --db $DBNAME"

    if [ -n "$DBUSER" ]; then
        CMD+=" --db-user \"$DBUSER\""
    fi

    if [ -n "$DBPASSWORD" ]; then
        CMD+=" --db-pwd \"$DBPASSWORD\""
    fi

    if ! run_vrunner "$CMD"; then
        log_error "Не удалось завершить сеансы пользователей (kill_sessions)"
        return $?
    fi

    log_info "Сеансы всех пользователей успешно завершены"
    return 0

}

lock_jobs() {

    DBNAME=$1
    DBUSER=$2
    DBPASSWORD=$3

    log_info "Начало блокировки регламентных заданий (lock_jobs)"

    CMD="scheduledjobs lock --ras $RAS_HOST --db $DBNAME"

    if [ -n "$DBUSER" ]; then
        CMD+=" --db-user \"$DBUSER\""
    fi

    if [ -n "$DBPASSWORD" ]; then
        CMD+=" --db-pwd \"$DBPASSWORD\""
    fi

    if ! run_vrunner "$CMD"; then
        log_error "Не удалось заблокировать работу регламентных заданий (lock_jobs)"
        return $?
    fi

    log_info "Регламентные задания заблокированы"
    return 0

}

unlock_jobs() {

    DBNAME=$1
    DBUSER=$2
    DBPASSWORD=$3

    log_info "Начало разблокировки регламентных заданий (unlock_jobs)"

    CMD="scheduledjobs unlock --ras $RAS_HOST --db $DBNAME"

    if [ -n "$DBUSER" ]; then
        CMD+=" --db-user \"$DBUSER\""
    fi

    if [ -n "$DBPASSWORD" ]; then
        CMD+=" --db-pwd \"$DBPASSWORD\""
    fi

    if ! run_vrunner "$CMD"; then
        log_error "Не удалось разблокировать работу регламентных заданий (lock_jobs)"
        return $?
    fi

    log_info "Регламентные задания разблокированы"
    return 0

}