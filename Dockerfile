FROM golang:1.13.4-alpine as build

RUN apk add --no-cache --update gcc musl-dev libtool make git
RUN mkdir -p /go/src/github.com/square/ghostunnel
RUN cd /go/src/github.com/square/ghostunnel && \
    git clone https://github.com/square/ghostunnel.git . && \
    GO111MODULE=on make clean ghostunnel && \
    cp ghostunnel /usr/bin/ghostunnel

FROM alpine
RUN apk add --no-cache --update libtool curl supervisor bind-tools
COPY --from=build /usr/bin/ghostunnel /usr/bin/ghostunnel

ENTRYPOINT ["/app/run.sh"]
