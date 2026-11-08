   FROM debian:bookworm

   RUN apt-get update && apt-get install -y --no-install-recommends nginx \
       && rm -rf /var/lib/apt/lists/*

   RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf

   COPY conf/static.conf /etc/nginx/conf.d/default.conf
   COPY site/ /var/www/static/

   RUN chmod -R a+rX /var/www/static

   EXPOSE 8081
   CMD ["nginx", "-g", "daemon off;"]
