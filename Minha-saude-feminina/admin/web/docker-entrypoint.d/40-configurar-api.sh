#!/bin/sh
set -eu

CONFIG_JS=/usr/share/nginx/html/assets/js/config.js
API_BASE_URL="${API_BASE_URL:-http://localhost:8080/api}"

sed -i "s#window.API_BASE_URL = '.*';#window.API_BASE_URL = '${API_BASE_URL}';#" "$CONFIG_JS"
