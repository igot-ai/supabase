# When you update this file substantially, please update build_your_own_images.md as well.
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.7@sha256:6910799b75ad41f00891978575a0d955be2f800c51b955af73926e7ab59a41c3

LABEL maintainer="Kong Docker Maintainers <docker@konghq.com> (@team-gateway-bot)"

ARG KONG_VERSION=3.5.0
ENV KONG_VERSION $KONG_VERSION

# RedHat required labels
LABEL name="Kong" \
      vendor="Kong" \
      version="$KONG_VERSION" \
      release="1" \
      url="https://konghq.com" \
      summary="Next-Generation API Platform for Modern Architectures" \
      description="Next-Generation API Platform for Modern Architectures"

# RedHat required LICENSE file approved path

ARG KONG_SHA256="aace6a1e95f07f0693101b604d7306b55e8ff817437c1fe1c60a6dfea79bdae1"

ARG KONG_PREFIX=/usr/local/kong
ENV KONG_PREFIX $KONG_PREFIX

ARG ASSET=remote
ARG EE_PORTS

COPY kong.rpm /tmp/kong.rpm

# hadolint ignore=DL3015
RUN set -ex; \
    if [ "$ASSET" = "remote" ] ; then \
      DOWNLOAD_URL="https://download.konghq.com/gateway-${KONG_VERSION%%.*}.x-rhel-8/Packages/k/kong-$KONG_VERSION.rhel8.amd64.rpm" \
      && curl -fL $DOWNLOAD_URL -o /tmp/kong.rpm \
      && echo "$KONG_SHA256  /tmp/kong.rpm" | sha256sum -c - \
      || exit 1; \
    fi \
    # findutils provides xargs (temporarily)
    && microdnf install --assumeyes --nodocs \
      findutils \
      shadow-utils \
      unzip \
      gettext \
    && rpm -qpR /tmp/kong.rpm \
      | grep -v rpmlib \
      | xargs -n1 -t microdnf install --assumeyes --nodocs \
    # Please update the rhel install docs if the below line is changed so that
    # end users can properly install Kong along with its required dependencies
    # and that our CI does not diverge from our docs.
    && rpm -iv /tmp/kong.rpm \
    && microdnf -y clean all \
    && rm /tmp/kong.rpm \
    && chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 ${KONG_PREFIX} \
    && ln -sf /usr/local/openresty/bin/resty /usr/local/bin/resty \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
    && kong version

COPY ./volumes/api/kong.entrypoint.sh /docker-entrypoint.sh

USER kong


EXPOSE 8000 8443 8001 8444 $EE_PORTS

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong-health

CMD ["kong", "docker-start"]
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

# Generate final config on startup
ENTRYPOINT ["bash", "-c", "eval \"echo \\\"$$(cat /home/kong/temp.yml)\\\"\" > /home/kong/kong.yml && /docker-entrypoint.sh kong docker-start"]
