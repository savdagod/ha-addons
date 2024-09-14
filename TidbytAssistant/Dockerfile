ARG BUILD_FROM

FROM $BUILD_FROM

# Args from HA add-on
# ARG BUILD_ARCH

# Args from build.yaml
ARG PIXLET_VERSION
ARG GO_VERSION

# Copy data for add-on
COPY TidbytPush.sh /opt
RUN chmod a+x /opt/TidbytPush.sh
COPY TidbytPublish.sh /opt
RUN chmod a+x /opt/TidbytPublish.sh
COPY TidbytText.sh /opt
RUN chmod a+x /opt/TidbytText.sh
COPY TidbytDelete.sh /opt
RUN chmod a+x /opt/TidbytDelete.sh
COPY hooks.yaml /
ADD display /opt/display

# Download pixlet binary and add to PATH
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    wget "https://github.com/tidbyt/pixlet/releases/download/v${PIXLET_VERSION}/pixlet_${PIXLET_VERSION}_linux_${arch}.tar.gz"
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    tar -xvf pixlet_${PIXLET_VERSION}_linux_${arch}.tar.gz -C /usr/local/bin
RUN chmod a+x /usr/local/bin/pixlet

# Download Go and add to PATH
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    wget "https://go.dev/dl/go${GO_VERSION}.linux-${arch}.tar.gz"
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    tar -xzf go${GO_VERSION}.linux-${arch}.tar.gz -C /usr/local
ENV PATH=${PATH}:/usr/local/go/bin

# Build Webhook binary using Go and move to PATH
RUN go install github.com/adnanh/webhook@latest
RUN mv /root/go/bin/webhook /usr/local/bin/webhook

# Install perl
RUN apk add --no-cache perl

CMD [ "webhook", "-hooks", "/hooks.yaml", "-verbose" ]