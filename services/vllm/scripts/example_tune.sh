#!/usr/bin/env bash
set -euo pipefail

python manage.py init --force
python manage.py render
python manage.py up
python manage.py benchmark --deployment default-chat
python manage.py tune --deployment default-chat --objective balanced --apply
python manage.py render
python manage.py up
