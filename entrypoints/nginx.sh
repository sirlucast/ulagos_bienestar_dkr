#!/usr/bin/env sh
export DOLLAR=$
rm -f /etc/nginx/conf.d/default.conf

# Espera que el servicio de api haya sido lanzado
echo "### DDT: NGINX -- WAITING FOR API"
export API_STATUS_CMD="wget --server-response --spider http://api:8000 2>&1 | grep "HTTP/" | awk '{print $2}'"
while [ -z "$(eval ${API_STATUS_CMD})" ]; do sleep 1s; done

# Espera que el servicio de vue haya sido lanzado
# echo "### DDT: NGINX -- WAITING FOR VUE"
# export VUE_STATUS_CMD="wget --server-response --spider http://vue:8080 2>&1 | grep "HTTP/" | awk '{print $2}'"
# while [ -z "$(eval ${VUE_STATUS_CMD})" ]; do sleep 1s; done

# Si no está en producción, se ejecuta con la configuración básica (sin SSL)
if [ "$DDT_ENV" != "prod" ]; then
	echo "### DDT: NGINX -- DEV"
    envsubst < ${DDT_ROOT}/templates/basic.conf > /etc/nginx/conf.d/local.conf
	nginx -g "daemon off;"
    exit
fi

export LETSENCRYPT_DIR=/etc/letsencrypt

# Si los certificados se crearon para dominios distintos, los elimina
if [ -e "${LETSENCRYPT_DIR}/ulagos_ssl_done" ] && [[ "$(cat ${LETSENCRYPT_DIR}/ulagos_ssl_done)" != "${DDT_API_DOMAINS} ${DDT_VUE_DOMAINS}" ]]; then
	echo "### DDT: NGINX -- OBSOLETE CERTIFICATE"
	rm -rf ${LETSENCRYPT_DIR}/ulagos_ssl_done
fi

# Si no están listos los certificados, se ejecuta con la configuración básica
# (sin SSL), y se reinicia apenas se hayan creado los certificados
if [ ! -e "${LETSENCRYPT_DIR}/ulagos_ssl_done" ]; then
	echo "### DDT: NGINX -- ACME-CHALLENGE"
    envsubst < ${DDT_ROOT}/templates/basic.conf > /etc/nginx/conf.d/local.conf
	nginx -g "daemon on;"
	while [ ! -e "${LETSENCRYPT_DIR}/ulagos_ssl_done" ]; do sleep 0.5s; done
	nginx -s stop
	exit
fi

# Se ejecuta con la configuración SSL, mientras en el background queda un loop
# infinito para revisar renovación
echo "### DDT: NGINX -- PRODUCTION"
envsubst < ${DDT_ROOT}/templates/ssl.conf > /etc/nginx/conf.d/local.conf
while :; do sleep 6h & wait $!; nginx -s reload; done & nginx -g "daemon off;"