FROM node:25-alpine3.23 as builder
WORKDIR /build
COPY . .
RUN npm install && npm run build

FROM nginx:1.29.8-alpine
COPY --from=builder /build/dist /usr/share/nginx/html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
RUN ln -s /usr/share/nginx/html /usr/share/nginx/html/momo-store
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]