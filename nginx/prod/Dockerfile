# build stage
FROM node:15.0-alpine as build-stage
WORKDIR /app/
COPY frontend/package.json /app/
RUN npm cache verify
RUN npm install --legacy-peer-deps
COPY frontend /app/
RUN npm run build

# production stage
FROM nginx:alpine as production-stage
ARG DDT_SRC_DIR
COPY nginx/prod/prod.conf /etc/nginx/prod.conf
COPY vol/static "${DDT_SRC_DIR}"/static/
COPY --from=build-stage /app/dist /dist/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
