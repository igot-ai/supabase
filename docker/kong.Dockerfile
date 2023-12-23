FROM kong:2.8.1

# Set environment variables from .env file
ENV KONG_DATABASE="off"
ENV KONG_DECLARATIVE_CONFIG="/home/kong/kong.yml"
ENV KONG_DNS_ORDER="LAST,A,CNAME"
ENV KONG_PLUGINS="request-transformer,cors,key-auth,acl,basic-auth"
ENV KONG_NGINX_PROXY_PROXY_BUFFER_SIZE="160k"
ENV KONG_NGINX_PROXY_PROXY_BUFFERS="64 160k"
# Copy config file
COPY ./volumes/api/kong.yml /home/kong/temp.yml

# Expose ports
EXPOSE ${KONG_HTTP_PORT} ${KONG_HTTPS_PORT}
RUN dnf install -y gettext && dnf clean all
# Generate final config on startup
ENTRYPOINT ["bash", "-c", "envsubst < /home/kong/temp.yml | tee /home/kong/kong.yml && /docker-entrypoint.sh kong docker-start"]
