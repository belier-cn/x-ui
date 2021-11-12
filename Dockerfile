FROM golang:1.16-alpine as builder

WORKDIR /x-ui

COPY . .

RUN CGO_ENABLED=1 go build -o x-ui .

FROM alpine

ARG TARGETARCH
ARG TARGETOS

WORKDIR /x-ui

RUN apk add --no-cache tzdata

ENV TZ Asia/Shanghai

COPY --from=builder /x-ui/x-ui  ./
COPY --from=builder /x-ui/bin/geoip.dat /x-ui/bin/geosite.dat /x-ui/bin/x-ray-$TARGETOS-$TARGETARCH ./bin/

EXPOSE 54321

ENTRYPOINT ["/x-ui/x-ui"]