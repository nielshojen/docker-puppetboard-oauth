#!/bin/sh

/bin/echo "Starting Puppetboard ..."
gunicorn -b 0.0.0.0:8000 puppetboard.app:app  &

if [[ ${ADMIN_USER} ]] && [[ ${ADMIN_PASS} ]]; then
    /bin/echo "Generating htpasswd file from env ..."
    /usr/bin/htpasswd -b -c /etc/nginx/htpasswd/puppetboard ${ADMIN_USER} ${ADMIN_PASS}
    /bin/echo "Starting nginx ..."
    /usr/sbin/nginx
elif [[ -f "/etc/nginx/htpasswd/puppetboard" ]]; then
    /bin/echo "Found htpasswd file ..."
    /bin/echo "Starting nginx ..."
    /usr/sbin/nginx
fi

if [[ -f "/etc/oauth2_proxy.cfg" ]]; then
    /bin/echo "Found oauth2 proxy config file ..."
    /bin/echo "Starting oauth2_proxy ..."
    /usr/local/bin/oauth2_proxy --upstream=http://0.0.0.0:8000
elif [[ ${OAUTH2_PROXY_COOKIE_SECRET} ]] && [[ ${OAUTH2_PROXY_EMAIL_DOMAINS} ]] && [[ ${OAUTH2_PROXY_CLIENT_SECRET} ]]; then
    /bin/echo "Starting oauth2_proxy with settings from env ..."
    /usr/local/bin/oauth2_proxy --upstream=http://0.0.0.0:8000
fi

tail -f /dev/null
