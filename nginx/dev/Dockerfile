FROM nginx:alpine

ARG DDT_SRC_DIR

COPY nginx/dev/dev.conf /etc/nginx/nginx.conf
COPY vol/static "${DDT_SRC_DIR}"/static/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
