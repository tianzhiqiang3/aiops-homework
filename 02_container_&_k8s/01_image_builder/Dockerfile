FROM golang:1.22.0 AS builder

ARG GOOS=linux
ARG GOARCH=amd64

WORKDIR /tcp_client_server

COPY . .

RUN go mod download \
  && CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -o tcp_client ./client/tcp_client.go \
  && CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -o tcp_server ./server/tcp_server.go

FROM ubuntu:20.04

COPY --from=builder /tcp_client_server/tcp_client /usr/local/bin/tcp_client
COPY --from=builder /tcp_client_server/tcp_server /usr/local/bin/tcp_server
