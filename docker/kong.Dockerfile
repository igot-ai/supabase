# When you update this file substantially, please update build_your_own_images.md as well.
FROM kong:2.8.1

COPY ./volumes/api/kong.yml /home/kong/temp.yml

# Generate final config on startup
CMD ["/bin/sh", "-c", "cat /home/kong/temp.yml | sed -e \"s/\$DASHBOARD_USERNAME/$DASHBOARD_USERNAME/g\" -e \"s/\$DASHBOARD_PASSWORD/$DASHBOARD_PASSWORD/g\" -e \"s/\$SUPABASE_ANON_KEY/$SUPABASE_ANON_KEY/g\" -e \"s/\$SUPABASE_SERVICE_KEY/$SUPABASE_SERVICE_KEY/g\" -e \"s/\$AUTH_VERIFY/$AUTH_VERIFY/g\" -e \"s/\$AUTH_CALLBACK/$AUTH_CALLBACK/g\" -e \"s/\$AUTH_AUTHORIZE/$AUTH_AUTHORIZE/g\" -e \"s/\$AUTH_HOST/$AUTH_HOST/g\" -e \"s/\$REST_RPC/$REST_RPC/g\" -e \"s/\$REST_RPC_GRAPHQL/$REST_RPC_GRAPHQL/g\" -e \"s/\$REALTIME_SOCKET_ENDPOINT/$REALTIME_SOCKET_ENDPOINT/g\" -e \"s/\$STORAGE_HOST/$STORAGE_HOST/g\" -e \"s/\$ANALYTIC_HOST/$ANALYTIC_HOST/g\" -e \"s/\$META_HOST/$META_HOST/g\" -e \"s/\$STUDIO_HOST/$STUDIO_HOST/g\" > /home/kong/kong.yml"]
ENTRYPOINT ["/docker-entrypoint.sh", "kong", "docker-start"]
