# -------- Build Stage --------
FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY DiscordBot/go.mod DiscordBot/go.sum ./
RUN go mod download

COPY DiscordBot .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app main.go


# -------- Runtime Stage --------
FROM alpine:3.20

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/app .

EXPOSE 6969

CMD ["./app"]
