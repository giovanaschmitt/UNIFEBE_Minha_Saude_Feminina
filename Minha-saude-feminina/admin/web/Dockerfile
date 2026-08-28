FROM nginx:1.27-alpine

COPY docker-entrypoint.d/40-configurar-api.sh /docker-entrypoint.d/40-configurar-api.sh
RUN chmod +x /docker-entrypoint.d/40-configurar-api.sh

COPY . /usr/share/nginx/html
RUN rm -rf /usr/share/nginx/html/docker-entrypoint.d

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
    CMD wget -qO- http://localhost/login.html || exit 1
