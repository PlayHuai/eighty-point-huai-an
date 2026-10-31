FROM golang:1.25-alpine AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
ARG SERVER_COMMIT
ARG SERVER_VERSION
ARG SERVER_CHANGELIST
RUN test -n "$SERVER_COMMIT" && test -n "$SERVER_VERSION" && test -n "$SERVER_CHANGELIST" && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath \
    -ldflags="-s -w -X github.com/Derek0120/eighty-point-huai-an/server/internal/buildinfo.Commit=$SERVER_COMMIT -X github.com/Derek0120/eighty-point-huai-an/server/internal/buildinfo.Version=$SERVER_VERSION -X github.com/Derek0120/eighty-point-huai-an/server/internal/buildinfo.ChangelistBase64=$SERVER_CHANGELIST" \
    -o /server ./cmd/server

FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /server /server
USER 65532:65532
ENTRYPOINT ["/server"]
