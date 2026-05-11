FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libfontconfig1 \
    libxcursor1 \
    libsqlite3-0 \ 
    && rm -rf /var/lib/apt/lists/*

WORKDIR /server

# Copy the executable and the custom library for gdsqlite addon to work in Linux arm64
COPY 10MinutesToKill_server.arm64 .
COPY libgdsqlite.linux.template_debug.arm64.so .

# Grant execution permission
RUN chmod +x 10MinutesToKill_server.arm64

# Add /server path to available paths in system where look for libraries
ENV LD_LIBRARY_PATH=/server

EXPOSE 28918/udp

CMD ["./10MinutesToKill_server.arm64", "--headless", "--server", "--port", "28918", "--maxplayers", "32"]
