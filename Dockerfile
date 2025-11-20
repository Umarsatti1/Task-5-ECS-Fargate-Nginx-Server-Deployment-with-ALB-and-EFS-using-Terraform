# Use a lightweight and secure NGINX base image
FROM nginx:stable-alpine

# Remove the default NGINX configuration so we can provide our own
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom NGINX configuration into the image
COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# Copy the static website files into the default web root directory
COPY /static/index.html /usr/share/nginx/html/index.html

# Expose port 80 so ECS and the ALB can forward traffic to the container
EXPOSE 80

# Start NGINX in the foreground (required for Docker containers)
CMD ["nginx", "-g", "daemon off;"]