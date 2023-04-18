# syntax=docker/dockerfile:1

FROM alpine:3.17

WORKDIR /app

COPY requirements.txt requirements.txt

RUN apk --no-cache --virtual build-dependencies add python3 \
                                                    py-pip

RUN python3 -m pip install -r requirements.txt

COPY . .

ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
