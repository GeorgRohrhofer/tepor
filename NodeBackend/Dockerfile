FROM gcc:15

WORKDIR /app

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update -qq && \
    apt-get install -y make git qt6-base-dev && \
    rm -rf /var/lib/apt/lists/* 


RUN wget https://github.com/Kitware/CMake/releases/download/v4.1.2/cmake-4.1.2-linux-x86_64.tar.gz
RUN tar -xzf cmake-4.1.2-linux-x86_64.tar.gz
RUN mv cmake-4.1.2-linux-x86_64 /opt/cmake
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

COPY . ./NodeBackend

RUN echo "Building NodeBackend..."
RUN cd NodeBackend && rm -rf build
RUN cd NodeBackend && mkdir -p build && cd build && cmake .. && cmake --build .
RUN mkdir -p /flyway
RUN touch /flyway/sqlite.db

WORKDIR /app/NodeBackend/build

ENTRYPOINT ["/app/NodeBackend/build/NodeBackend"]

