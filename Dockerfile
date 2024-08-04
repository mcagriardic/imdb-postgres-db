FROM postgres:15

# Install necessary tools
RUN apt-get update && apt-get install -y wget

# Set environment variables
ENV POSTGRES_DB=database
ENV POSTGRES_USER=username
ENV POSTGRES_PASSWORD=password

# Copy SQL scripts and import script
COPY init.sql /docker-entrypoint-initdb.d/
COPY post_import.sql /docker-entrypoint-initdb.d/
COPY import_data.sh /docker-entrypoint-initdb.d/

# Copy custom entrypoint script
COPY custom-entrypoint.sh /usr/local/bin/

# Make the scripts executable
RUN chmod +x /docker-entrypoint-initdb.d/import_data.sh && \
    chmod +x /usr/local/bin/custom-entrypoint.sh

# Set PostgreSQL configuration
RUN echo "max_wal_size = 4GB" >> /usr/share/postgresql/postgresql.conf.sample
RUN echo "checkpoint_completion_target = 0.9" >> /usr/share/postgresql/postgresql.conf.sample

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]

# Default command
CMD ["postgres"]