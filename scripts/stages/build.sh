#!/usr/bin/env bash

# ========== ПОДКЛЮЧЕНИЕ МОДУЛЕЙ ==========
BUILD_FOLDER="$CI_BUILD_ROOT/scripts/build"
source "$BUILD_FOLDER/git-repo-downloader.sh" || exit 1
source "$BUILD_FOLDER/cf-unload.sh" || exit 1
source "$BUILD_FOLDER/cfe-edt-builder.sh" || exit 1

# if ! upload_cf; then
#     exit 1;
# fi


# if ! download_extensions; then
#     exit 1; 
# fi

# if ! build_cfes; then
#     exit 1;
# fi


exit 0