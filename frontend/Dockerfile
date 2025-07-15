# Use official Nginx base image
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default index.html (optional but clean)
RUN rm -rf ./*

# Copy your custom HTML
COPY index.html .
COPY styles.css .

# Expose port 80
EXPOSE 80

# Use the default nginx  command
CMD ["nginx", "-g", "daemon off;"]
