FROM python:3.10.10-slim
ADD . /app
WORKDIR /app/
ARG APP_USER=appuser
RUN groupadd -r ${APP_USER} && useradd --no-log-init --create-home -r -g ${APP_USER} ${APP_USER}


RUN set -ex \
    && RUN_DEPS=" \
    libpcre3 \
    mime-support \
    postgresql-client \
    libmariadb-dev-compat libmariadb-dev \
    git \
    graphviz \
    " \
    && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
    && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS \
    && rm -rf /var/lib/apt/lists/*


RUN set -ex \
    && BUILD_DEPS=" \
    build-essential \
    libpcre3-dev \
    libpq-dev" \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install python dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt


RUN chown -R ${APP_USER}:${APP_USER} /app
COPY docker/.bashrc /root/.bashrc
COPY docker/.bashrc /home/appuser/.bashrc
# uWSGI will listen on this port
EXPOSE 8000
# Base uWSGI configuration (you shouldn't need to change these):
# get APP_USER ID from host
ENV DJANGO_SETTINGS_MODULE=core.settings
ENV UWSGI_WSGI_FILE=core/wsgi.py UWSGI_HTTP=:8000 UWSGI_MASTER=1 UWSGI_HTTP_AUTO_CHUNKED=1 UWSGI_HTTP_KEEPALIVE=1 UWSGI_LAZY_APPS=1 UWSGI_WSGI_ENV_BEHAVIOR=holy


USER ${APP_USER}:${APP_USER}
# gunicorn
CMD ["uwsgi", "--show-config"]

