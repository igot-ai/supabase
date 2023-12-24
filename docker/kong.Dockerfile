# When you update this file substantially, please update build_your_own_images.md as well.
FROM kong:2.8.1

# Generate final config on startup
ENTRYPOINT ["/docker-entrypoint.sh", "kong", "docker-start"]
