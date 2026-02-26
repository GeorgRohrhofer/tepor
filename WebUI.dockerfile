FROM debian:latest AS build-env

RUN apt-get update

RUN apt install -y curl file git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev
RUN apt-get clean

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v
RUN flutter channel master
RUN flutter upgrade

RUN flutter config --enable-web

RUN mkdir /app/
COPY WebUI/managementserver_frontend /app/
WORKDIR /app/

RUN flutter build web --dart-define=API_URL=http://localhost:3333 --release

FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80
