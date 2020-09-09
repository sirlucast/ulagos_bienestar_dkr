#!/usr/bin/env sh

# Si no está en producción, inicia el servidor de desarrollo de vue.js
if [ "$DDT_ENV" != "prod" ]; then
	echo "### DDT: VUE -- DEV"
	npm run serve
	exit
fi

# Si esta en producción, "compila" el codigo de vue.js
echo "### DDT: VUE -- BUILDING"
npm run build || exit 1

# # Sirve los archivos compilados
echo "### DDT: VUE -- HTTP-SERVER"
http-server dist