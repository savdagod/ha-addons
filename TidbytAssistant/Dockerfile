ARG BUILD_FROM=homeassistant/amd64-base:latest

FROM ${BUILD_FROM} AS builder

# Args from build.yaml
ARG GO_VERSION=1.23.6

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Download Go and add to PATH
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-${arch}.tar.gz"
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    tar -xzf "go${GO_VERSION}.linux-${arch}.tar.gz" -C /usr/local && \
    rm "go${GO_VERSION}.linux-${arch}.tar.gz"
ENV PATH=/usr/local/go/bin:${PATH}
ENV GOROOT=/usr/local/go

# Download dependencies
RUN apk --no-cache add libc-dev gcc ca-certificates libwebp-dev libwebp-static tzdata

# Build binary
COPY *.go go.mod go.sum /src/
WORKDIR /src
RUN CGO_ENABLED=1 go build -ldflags "-s -w -linkmode=external '-extldflags=-static -lsharpyuv'" -o /tidbyt-assistant ./...

FROM scratch

COPY --from=builder /tidbyt-assistant /tidbyt-assistant
#COPY --from=builder /usr/lib/libwebp*.so* /usr/lib/libsharpyuv.so* /usr/lib/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY display /display

ENTRYPOINT [ "/tidbyt-assistant" ]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "/tidbyt-assistant", "-health", "http://localhost:9000/health" ]
