FROM golang:1.16-alpine as builder

WORKDIR /x-ui

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache build-base

ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct

COPY ./go.mod ./go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=1 go build -a -o x-ui main.go

FROM alpine:3.13

ARG TARGETARCH
ARG TARGETOS

WORKDIR /x-ui

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache tzdata

ENV TZ Asia/Shanghai

COPY --from=builder /x-ui/x-ui  ./
COPY --from=builder /x-ui/bin/geoip.dat /x-ui/bin/geosite.dat /x-ui/bin/x-ray-$TARGETOS-$TARGETARCH ./bin/

EXPOSE 54321

ENTRYPOINT ["/x-ui/x-ui"]