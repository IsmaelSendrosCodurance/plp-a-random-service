FROM --platform=linux/amd64 python:3.12-slim

RUN apt-get update && apt-get install -y libpq-dev gcc

WORKDIR /

COPY pyproject.toml /

ARG VCS_REF
ENV VCS_REF=$VCS_REF

RUN pip3 install poetry
RUN poetry config virtualenvs.create false
RUN poetry install --no-dev

COPY service /service

EXPOSE 8080

ENTRYPOINT ["poetry","run","start"]