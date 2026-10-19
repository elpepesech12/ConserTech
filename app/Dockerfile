FROM nginx:alpine

# Copia los archivos que compilaste localmente al servidor Nginx
COPY build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]