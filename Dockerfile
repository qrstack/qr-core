FROM python:3.10.9-slim-buster

LABEL maintainer="qrstack"
LABEL vendor="qr-core"

ARG APP_ENVIRONMENT
ENV APP_ENVIRONMENT=${APP_ENVIRONMENT} \
    # python:
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1 \
    # pip:
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    # poetry:
    POETRY_VERSION=1.1.13 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR='/var/cache/pypoetry' \
    POETRY_HOME='/usr/local'

RUN apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        openssh-server \
        netcat \
        build-essential \
        curl \
        gettext \
        git \
        libpq-dev \
        python-openssl \
        python-mysqldb \
        libmagic1 \
        default-libmysqlclient-dev \
    # Installing `poetry` package manager:
    # https://github.com/python-poetry/poetry
    && curl -sSL 'https://install.python-poetry.org' | python - \
    && poetry --version \
    # Cleaning cache
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" >> /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Copy only requirement to cache in docker layer
#COPY ./poetry.lock ./pyproject.toml /usr/src/app/
#
#RUN echo "$APP_ENVIRONMENT" \
#    && poetry version \
#    && poetry run pip install -U pip \
#    && poetry install \
#      $(if [ "$APP_ENVIRONMENT" = 'production' ]; then echo '--only main'; fi) \
#      --no-interaction --no-ansi --no-root

COPY requirements.txt /usr/src/app/
COPY /requirements /usr/src/app/requirements

RUN echo "$APP_ENVIRONMENT" \
    && python3 -m pip install -r requirements.txt

#COPY ./docker-entrypoint.sh ./docker-entrypoint.sh

#RUN ["chmod", "+x", "/usr/src/app/docker-entrypoint.sh"]

#ENTRYPOINT ["./docker-entrypoint.sh"]

COPY . .
