FROM kong:2.8.1

# Set environment variables from .env file
ENV KONG_HTTP_PORT=${KONG_HTTP_PORT}
ENV KONG_HTTPS_PORT=${KONG_HTTPS_PORT}
ENV KONG_DATABASE="off"
ENV KONG_DECLARATIVE_CONFIG="/home/kong/kong.yml"
ENV KONG_DNS_ORDER="LAST,A,CNAME"
ENV KONG_PLUGINS="request-transformer,cors,key-auth,acl,basic-auth"
ENV KONG_NGINX_PROXY_PROXY_BUFFER_SIZE="160k"
ENV KONG_NGINX_PROXY_PROXY_BUFFERS="64 160k"
ENV SUPABASE_ANON_KEY=${ANON_KEY}
ENV SUPABASE_SERVICE_KEY=${SERVICE_ROLE_KEY}
ENV DASHBOARD_USERNAME=${DASHBOARD_USERNAME}
ENV DASHBOARD_PASSWORD=${DASHBOARD_PASSWORD}
RUN addgroup -S kong && adduser -S -g kong kong
USER kong
# Copy config file
COPY ./volumes/api/kong.yml /home/kong/temp.yml

# Expose ports
EXPOSE ${KONG_HTTP_PORT} ${KONG_HTTPS_PORT}

# Generate final config on startup
ENTRYPOINT ["bash", "-c", "eval \"echo \\\"$$(cat /home/kong/temp.yml)\\\"\" > /home/kong/kong.yml && /docker-entrypoint.sh kong docker-start"]
