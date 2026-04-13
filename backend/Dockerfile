FROM golang:1.23-alpine3.22 as builder
WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o momo-backend ./cmd/api

FROM alpine:3.22
WORKDIR /app
COPY --from=builder --chmod=+x /build/momo-backend .
RUN useradd -M -s /usr/sbin/nologin momouser && chown -R momouser:momouser /app
USER momouser
ENTRYPOINT ["/app/momo-backend"]