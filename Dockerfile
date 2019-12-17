FROM python:3.6.9-slim-stretch

# Versions
ARG AIRFLOW_VERSION=1.10.3
ARG CLOUD_SDK_VERSION=273.0.0
ARG AIRFLOW_DEPS="slack,google_auth,kubernetes"
ARG PYTHON_DEPS=""

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=linux

# Define en_US.
ENV LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LC_MESSAGES=en_US.UTF-8 \
    # The flask version is hardcoded to 1.0.4, this is needed for airflow 1.10.3
    FLASK_VERSION=1.0.4 \
    REDIS_VERSION=3.2 \
    AIRFLOW_GPL_UNIDECODE=yes

RUN set -ex \
    && buildDeps=' \
freetds-dev \
libkrb5-dev \
libsasl2-dev \
libssl-dev \
libffi-dev \
libpq-dev \
' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        apt-utils \
        build-essential \
        curl \
        default-libmysqlclient-dev \
        freetds-bin \
        git \
        gnupg2 \
        libpq5 \
        locales \
        netcat \
        rsync \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && pip install -U pip setuptools psycopg2-binary \
    && pip install flask==$FLASK_VERSION \
    && pip install google-api-python-client \
    && pip install google-cloud-storage \
    && pip install grpcio-tools \
    && pip install google-cloud \
    && pip install google-cloud-container \
    && pip install grpcio \
    && pip install httplib2 \
    && pip install ndg-httpsclient \
    && pip install oauth2client \
    && pip install pandas-gbq \
    && pip install pyasn1 \
    && pip install pyOpenSSL \
    && pip install pytest \
    && pip install pytz \
    && pip install "redis==${REDIS_VERSION}" \
    && pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz

ENV PATH $PATH:/google-cloud-sdk/bin

# RUN echo "----- debug ------" \
#     && python --version \
#     && gcloud --version \
#     && airflow version

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]