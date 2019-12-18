# PyTest for airflow in Docker

This dockerfile contains python and all dependencies to run pytest tests of airflow jobs.
Installing python dependencies takes multiple minutes, so we prefer to do this once in a dockerfile rather than before every test. It is also used by the dockerfile for local execution.


## Build

```bash
docker build . -t python-airflow:3.6.9_1.10.3_273.0.0
```

The tag is a combination of Python & Airflow & GCloud versions


## Usage

Mount the source code you would like to test in `/src`. For example

```bash
docker run --rm -it . -v {PATH_TO_CODE}:/src python-airflow
```

### Debugging

Launch bash in the container with

```bash
docker run --rm -it --entrypoint=/bin/bash -v {PATH_TO_CODE}:/src python-airflow
```


## Contributing

Contributions are welcomed! Read the [Contributing Guide](CONTRIBUTING.md) for more information.

## Licensing

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
