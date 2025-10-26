FROM gcc:13

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y cmake make git && \
    rm -rf /var/lib/apt/lists/*

COPY . ./NodeBackend

RUN echo "Building NodeBackend..."
RUN cd NodeBackend && rm -rf build
RUN cd NodeBackend && mkdir -p build && cd build && cmake .. && cmake --build .

WORKDIR /app/NodeBackend/build

CMD ["/app/NodeBackend/build/NodeBackend"]

