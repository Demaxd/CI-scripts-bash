#!/usr/bin/env bash

LOG_FILE="$CI_BUILD_ROOT/ci_build.log"

# ========== ФУНКЦИИ ЛОГИРОВАНИЯ ==========
log_info() {
    printf "[%(%Y-%m-%d %H:%M:%S)T] [INFO] %s\n" -1 "$*" | tee -a "$LOG_FILE"
}

log_warn() {
    printf "[%(%Y-%m-%d %H:%M:%S)T] [WARN] %s\n" -1 "$*" | tee -a "$LOG_FILE" >&2
}

log_error() {
    printf "[%(%Y-%m-%d %H:%M:%S)T] [ERROR] %s\n" -1 "$*" | tee -a "$LOG_FILE" >&2
}

print_separator() {
    log_info "=========================================="
}