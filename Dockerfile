FROM python:3.6.6-slim-stretch

# Versions
# Check constraints: https://github.com/apache/airflow/blob/constraints-1-10/constraints-3.8.txt
ARG AIRFLOW_VERSION=1.10.15
ARG CLOUD_SDK_VERSION=340.0.0
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
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN pip install "pip==21.1.1" \
    && pip install "setuptools==56.2.0" \
    && pip install "psycopg2-binary==2.8.6" \
    # Add dataclasses, a python 3.7 feature, to python 3.6. Remove for python version 3.7+ \
    && pip install "dataclasses==0.8" \
    && pip install "SQLAlchemy==1.3.23" \
    && pip install "Flask-SQLAlchemy==2.4.4" \
    && pip install "Flask==1.1.2" \
    && pip install "google-api-python-client==1.7.8" \
    && pip install "google-cloud-storage==1.13.2" \
    && pip install "grpcio-tools==1.37.1" \
    && pip install "google-cloud-container==0.2.1" \
    && pip install "google-cloud-datacatalog==3.1.1" \
    && pip install "grpcio==1.37.1" \
    && pip install "httplib2==0.19.1" \
    && pip install "ndg-httpsclient==0.5.1" \
    && pip install "oauth2client==4.1.3" \
    && pip install "pandas-gbq==0.14.1" \
    && pip install "pyasn1==0.4.8" \
    && pip install "pyOpenSSL==20.0.1" \
    && pip install "pytest==6.2.4" \
    && pip install "mock==4.0.3" \
    && pip install "pytest-mock==3.6.1" \
    && pip install "pytz==2021.1" \
    && pip install "redis==3.5.3" \
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


# Follow instructions on https://cloud.google.com/sdk/docs/downloads-apt-get
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
&& apt-get update -y \
&& apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
kubectl && gcloud --version


COPY entrypoint.sh /entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
