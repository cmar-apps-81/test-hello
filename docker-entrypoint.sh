#!/usr/bin/env sh

set -e 

until $(python3 testPostgresConnection.py); do echo '=> Waiting for PostgreSQL to start...'; sleep 2; done

python3 -m flask --app app db init || echo "Skip init db."
python3 -m flask --app app db migrate || echo "Skip migrate db."
python3 -m flask --app app db upgrade || echo "Skip upgrade db."

exec python3 -m flask run --host=0.0.0.0 --port=8000
