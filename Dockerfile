FROM python:3.9-alpine3.13
LABEL maintainer="londonappdeveloper.com"

ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY ./requirements.txt ./requirements.dev.txt ./

COPY ./scripts /scripts

ARG DEV

RUN python -m venv /py && \
  /py/bin/pip install --upgrade pip && \
  apk add --update --no-cache postgresql-client jpeg-dev && \
  apk add --update --no-cache --virtual .tmp-build-deps \
  build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
  /py/bin/pip install -r /app/requirements.txt && \
  if [ $DEV = "true" ]; \
  then /py/bin/pip install -r /app/requirements.dev.txt; \
  fi && \
  apk del .tmp-build-deps && \
  adduser \
    --disabled-password \
    --no-create-home \
    django-user && \
  mkdir -p /vol/web/media && \
  mkdir -p /vol/web/static && \
  chown -R django-user:django-user /vol && \
  chmod -R 755 /vol && \
  chmod -R +x /scripts

COPY . .

WORKDIR /app/app

EXPOSE 8000

ENV PATH="/scripts:/py/bin:$PATH"

USER django-user

CMD ["run.sh"]
