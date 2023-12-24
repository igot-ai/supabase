# When you update this file substantially, please update build_your_own_images.md as well.
FROM kong:2.8.1

COPY ./volumes/api/kong.yml /home/kong/temp.yml

# Expose ports
EXPOSE 8000 8443

# Generate final config on startup
ENTRYPOINT ["bash", "-c", "eval \"echo \\\"$$(cat /home/kong/temp.yml)\\\"\" > /home/kong/kong.yml && /docker-entrypoint.sh kong docker-start"]
