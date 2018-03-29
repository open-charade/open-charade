#!/bin/bash

# Start Gunicorn processes
echo Starting Gunicorn.
ls
exec gunicorn open_charade.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 3