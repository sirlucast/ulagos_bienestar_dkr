#!/usr/bin/env sh
export DOLLAR=$
rm -f /etc/nginx/conf.d/default.conf

# Espera que el servicio de backend haya sido lanzado
echo "### DDT: NGINX -- WAITING FOR BACKEND"
export API_STATUS_CMD="wget --server-response --spider http://backend:8000 2>&1 | grep "HTTP/" | awk '{print $2}'"
while [ -z "$(eval ${API_STATUS_CMD})" ]; do sleep 1s; done