FROM gcc:15

WORKDIR /app

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

WORKDIR /app/NodeBackend/build

CMD ["/app/NodeBackend/build/NodeBackend"]

