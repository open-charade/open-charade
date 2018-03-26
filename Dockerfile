# Dockerfile

# FROM directive instructing base image to build upon
FROM python:3.6-onbuild

ADD requirements.txt /tmp/pip/requirements.txt

WORKDIR /tmp/pip
RUN pip install --no-cache-dir -r requirements.txt

# COPY startup script into known file location in container
COPY deploy/start.sh /app/start.sh

# EXPOSE port 8000 to allow communication to/from server
EXPOSE 8000

ADD manage.py /app/
ADD db.sqlite3 /app/
ADD open_charade /app/open_charade/
VOLUME ["/app"]
WORKDIR /app
# CMD specifcies the command to execute to start the server running.
CMD ["/app/start.sh"]
# done!