# PyTest for airflow in Docker

This dockerfile contains python and all dependencies to run pytest tests of airflow jobs.
Installing python dependencies takes multiple minutes, so we prefer to do this once in a dockerfile rather than before every test. It is also used by the dockerfile for local execution.

## Local Build

```bash
docker build . -t python-airflow:local
```

## CI Build

The image is hosted in quay.io: https://quay.io/repository/travelaudience/pytest-airflow-docker

A git tag can be used to trigger a new build. The convention used is:
```
3.6.9_1.10.3_276.0.0_1.0.1
```
This is a combination of Python & Airflow & GCloud & docker image versions.


## Usage

Mount the source code you would like to test in `/src`. For example

```bash
docker run --rm -it . -v {PATH_TO_CODE}:/src quay.io/travelaudience/pytest-airflow-docker:3.6.9_1.10.3_273.0.0
```

### Debugging

Launch bash in the container with

```bash
docker run --rm -it --entrypoint=/bin/bash -v {PATH_TO_CODE}:/src quay.io/travelaudience/pytest-airflow-docker:3.6.9_1.10.3_273.0.0
```


## Contributing

Contributions are welcomed! Read the [Contributing Guide](CONTRIBUTING.md) for more information.

## Licensing

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
