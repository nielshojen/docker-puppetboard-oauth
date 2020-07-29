FROM python:3.8-alpine

ENV PUPPETBOARD_PORT 8000

EXPOSE 80
EXPOSE 443
EXPOSE 4180
EXPOSE 8000

ENV PUPPETBOARD_SETTINGS docker_settings.py
RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app/

# Workaround for https://github.com/benoitc/gunicorn/issues/2160
RUN apk --update --no-cache add libc-dev binutils

RUN apk update && \
    apk add nginx && \
    adduser -D -g 'www' www && chown -R www:www /var/lib/nginx && \
    mkdir /run/nginx && \
    mkdir /etc/nginx/htpasswd && \
    apk add apache2-utils && \
    wget -P /tmp https://github.com/pusher/oauth2_proxy/releases/download/v4.0.0/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    tar -C /tmp -zxvf /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    rm /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz && \
    mv /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1/oauth2_proxy /usr/local/bin/oauth2_proxy && \
    rm -rf /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1

COPY requirements*.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements-docker.txt

COPY . /usr/src/app

RUN chmod +x /usr/src/app/run.sh

CMD /usr/src/app/run.sh
