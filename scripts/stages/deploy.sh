#!/usr/bin/env bash

# ========== ПОДКЛЮЧЕНИЕ МОДУЛЕЙ ==========
DEPLOY_FOLDER="$CI_BUILD_ROOT/scripts/deploy"
source "$DEPLOY_FOLDER/cf-load.sh" || exit 1

# if ! load_cf; then
#     exit 1;
# fi

# if ! load_cfes; then
#     exit 1;
# fi

exit 0