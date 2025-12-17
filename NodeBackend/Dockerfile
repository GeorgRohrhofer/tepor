FROM gcc:15 as cpp-build

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

#--------------------------------------------------------------
# Building Monitoring and WorldSync
#--------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS csharp-build
WORKDIR /build/csharp
COPY ../MonitoringService/Client/ClientMonitoringService/ ./MonService
WORKDIR /build/csharp/MonService
RUN dotnet publish \
    -c Release \
    -r linux-musl-x64 \
    --self-contained true \
    /p:PublishSingleFile=true \
    -o /out/BackupSyncService

WORKDIR /build/csharp
COPY ../WorldSynchronization/BackupSyncService/Client/ ./WorldSync
WORKDIR /build/csharp/WorldSync
RUN dotnet publish \
    -c Release \
    -r linux-musl-x64 \
    --self-contained true \
    /p:PublishSingleFile=true \
    -o /out/BackupSyncService

WORKDIR /app/NodeBackend/build

ENTRYPOINT ["/app/NodeBackend/build/NodeBackend"]

#--------------------------------------------------------------
# Runtime
#--------------------------------------------------------------

FROM alpine:3.20
RUN apk add --no-cache libstdc++ ca-certificates

WORKDIR /app

# C++ Binary
COPY --from=cpp-build /app/NodeBackend/build/NodeBackend ./NodeBackend

# C# Binary (single file executable)
COPY --from=csharp-build /out/* ./ClientMonitoringService
COPY --from=csharp-build /out/* ./Client

RUN chmod +x ./cpp-app ./csharp-app

CMD ["./NodeBackend"]
