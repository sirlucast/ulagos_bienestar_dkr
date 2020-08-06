#!/usr/bin/env sh

# Espera por la base de datos
echo "### DDT: API -- WAITING FOR DB"
python ${DDT_ROOT}/src/manage.py wait_db || exit 1

# Revisa si faltan migraciones que crear
echo "### DDT: API -- CHECK PENDING MIGRATIONS"
python ${DDT_ROOT}/src/manage.py makemigrations --check --dry-run --no-input || exit 1

# Intenta migrar
echo "### DDT: API -- MIGRATE"
python ${DDT_ROOT}/src/manage.py migrate --no-input || exit 1

# Recolecta los archivos estáticos y ejecuta servidor gunicorn
echo "### DDT: API -- GUNICORN"
python ${DDT_ROOT}/src/manage.py collectstatic --no-input \
&& gunicorn ${DDT_ROOT_NAME}.wsgi:application \
	$([ "${DDT_ENV}" != "prod" ] && echo "--reload" || echo "--preload") \
	--name ${DDT_ROOT_NAME} \
	--log-level $([ ${DDT_ENV} != "prod" ] && echo "info" || echo "warning") \
	--access-logfile '-' --error-logfile '-' \
	--workers 2 --threads 4 --worker-class gthread --worker-tmp-dir /dev/shm \
	--bind 0.0.0.0:8000