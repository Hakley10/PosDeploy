# Stage 1
FROM node:20-alpine AS build

ARG API_BASE_URL
ARG FILE_BASE_URL
ARG WEB_BASE_URL
ARG SOCKET_URL

ENV API_BASE_URL=${API_BASE_URL}
ENV FILE_BASE_URL=${FILE_BASE_URL}
ENV WEB_BASE_URL=${WEB_BASE_URL}
ENV SOCKET_URL=${SOCKET_URL}
ENV NODE_OPTIONS=--max_old_space_size=2048

WORKDIR /usr/app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm run build

# Stage 2
FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /usr/app/dist /usr/share/nginx/html
