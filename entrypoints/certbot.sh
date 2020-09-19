#!/usr/bin/env sh

# Espera que el servicio de nginx haya sido lanzado
echo "### DDT: NGINX -- WAITING FOR NGINX"
export NGINX_STATUS_CMD="wget --server-response --spider http://nginx:80 2>&1 | grep "HTTP/" | awk '{print $2}'"
while [ -z "$(eval ${NGINX_STATUS_CMD})" ]; do sleep 1s; done

# Si no está en producción, no hace nada y espera a ser terminado
if [ "$DDT_ENV" != "prod" ]; then
	echo "### DDT: CERTBOT -- DEV"
	trap exit TERM; while :; do sleep 12h & wait $!; done;
    exit
fi

export LETSENCRYPT_DIR=/etc/letsencrypt

# Crea el certificado si no existe
if [ ! -e "${LETSENCRYPT_DIR}/ulagos_ssl_done" ]; then
	echo "### DDT: CERTBOT -- NEW CERTIFICATE"

	if [ ! -e "${LETSENCRYPT_DIR}/options-ssl-nginx.conf" ]; then
		wget -O ${LETSENCRYPT_DIR}/options-ssl-nginx.conf \
			https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf
	fi

	if [ ! -e "${LETSENCRYPT_DIR}/ssl-dhparams.pem" ]; then
		wget -O ${LETSENCRYPT_DIR}/ssl-dhparams.pem \
			https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem
	fi

    # Si se desean hacer pruebas, es necesario agregar argumento --staging
    # para no superar el rate limit semanal
	certbot certonly --non-interactive --webroot --webroot-path ${DDT_ROOT}/certbot \
		--cert-name ${DDT_SSL_NAME} --email ${DDT_SSL_MAIL} --agree-tos \
		--domains ${DDT_API_DOMAINS// /,},${DDT_VUE_DOMAINS// /,} --force-renewal

	if [ $? -eq 0 ]; then
		echo "${DDT_API_DOMAINS} ${DDT_VUE_DOMAINS}" > ${LETSENCRYPT_DIR}/ulagos_ssl_done
		sleep 2s
		echo "### DDT: CERTBOT -- CERTIFICATE SUCCESS"
	else
		echo "### DDT: CERTBOT -- CERTIFICATE FAILURE"
	fi
	exit
fi

# Loop infinito para revisar renovación
echo "### DDT: CERTBOT -- RENEW LOOP"
trap exit TERM; while :; do certbot renew; sleep 12h & wait $!; done;