# Nginx Dockerfile for Laravel Application
FROM nginx:alpine

# Install additional packages
RUN apk add --no-cache \
    curl \
    bash

# Copy custom nginx configuration
COPY docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Copy SSL configuration (if any)
COPY docker/nginx/ssl /etc/nginx/ssl

# Copy static files from Laravel public directory
COPY src/public /var/www/html/public

# Set proper permissions
RUN chown -R nginx:nginx /var/www/html \
    && chmod -R 755 /var/www/html

# Add health check script
RUN echo '#!/bin/bash' > /usr/local/bin/health-check.sh && \
    echo 'curl -f http://localhost/health || exit 1' >> /usr/local/bin/health-check.sh && \
    chmod +x /usr/local/bin/health-check.sh

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
