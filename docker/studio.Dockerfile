# Use the supabase/postgres-meta image
FROM supabase/postgres-meta:v0.75.0

# Set environment variables
ENV PG_META_PORT=8080
ENV PG_META_DB_HOST=${POSTGRES_HOST}
ENV PG_META_DB_PORT=${POSTGRES_PORT}
ENV PG_META_DB_NAME=${POSTGRES_DB}
ENV PG_META_DB_USER=supabase_admin
ENV PG_META_DB_PASSWORD=${POSTGRES_PASSWORD}

# Expose the port
EXPOSE ${PG_META_PORT}
