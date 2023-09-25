FROM python:3.9-alpine3.13
LABEL maintainer="londonappdeveloper.com"

ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY ./requirements.txt ./requirements.dev.txt ./

ARG DEV

RUN python -m venv /py && \
  /py/bin/pip install --upgrade pip && \
  apk add --update --no-cache postgresql-client && \
  apk add --update --no-cache --virtual .tmp-build-deps \
  build-base postgresql-dev musl-dev && \
  /py/bin/pip install -r /app/requirements.txt && \
  if [ $DEV = "true" ]; \
  then /py/bin/pip install -r /app/requirements.dev.txt; \
  fi && \
  apk del .tmp-build-deps && \
  adduser \
  --disabled-password \
  --no-create-home \
  django-user

COPY . .

WORKDIR /app/src

EXPOSE 8000

ENV PATH="/py/bin:$PATH"

USER django-user

CMD ["sh", "-c", "python manage.py runserver 0.0.0.0:8000"]
