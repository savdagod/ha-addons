ARG BUILD_FROM

FROM $BUILD_FROM

# Args from build.yaml
ARG GO_VERSION

# Copy data for add-on
COPY start.sh /
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

# Download Go and add to PATH
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    wget "https://go.dev/dl/go${GO_VERSION}.linux-${arch}.tar.gz"
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    tar -xzf go${GO_VERSION}.linux-${arch}.tar.gz -C /usr/local && \
    rm go${GO_VERSION}.linux-${arch}.tar.gz
ENV PATH=${PATH}:/usr/local/go/bin

# Build Webhook binary using Go and move to PATH
RUN go install github.com/adnanh/webhook@latest
RUN mv /root/go/bin/webhook /usr/local/bin/webhook

# Download dependencies
ENV GOPATH /usr/local/go
ENV REPO $GOPATH/pixlet
RUN apk update && \
    apk upgrade -U && \
    apk add --no-cache perl && \
    apk add curl wget git make libc-dev gcc ca-certificates npm libwebp-dev libwebp-tools patchelf gcompat && \
    rm -rf /var/cache/*

# Download Pixlet
RUN git clone https://github.com/savdagod/pixlet.git $REPO 
WORKDIR $REPO

#Build Pixlet
RUN npm install && npm run build
RUN make build

# Move pixlet binary to path
RUN mv $GOPATH/pixlet/pixlet /usr/local/bin/pixlet

# Clean up build prereqs
RUN apk del -r curl wget git make gcc patchelf libc-dev 
RUN rm -r $GOPATH
RUN rm -r /root/go

# CMD [ "webhook", "-hooks", "/hooks.yaml", "-verbose" ]
CMD ["/start.sh"]
