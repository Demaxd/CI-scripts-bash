#!/usr/bin/env bash

# ========== ПОДКЛЮЧЕНИЕ ОБЩИХ ФУНКЦИЙ ==========
source "$CI_BUILD_ROOT/scripts/common/logging.sh" || exit 1
source "$CI_BUILD_ROOT/scripts/common/env-setup.sh" || exit 1
source "$CI_BUILD_ROOT/scripts/common/config-reader.sh" || exit 1

check_can_apply_exts() {

    EXT_NAME=$1

    print_separator
    log_info "Проверка возможности применения расширения(-ий)"

    # В vrunner 2.x еще не доступно
    CMD=""

    if [ -n "$EXT_NAME" ]; then
        
    fi


}
