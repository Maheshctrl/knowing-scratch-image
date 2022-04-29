# base image
FROM golang:1.18.1 AS builder
# create non-root user
RUN useradd -u 10001 scratchuser
# set up work directory
WORKDIR /app
# copy files and build app
COPY . .
RUN CGO_ENABLED=0 go build -o /go/bin/app .


# final stage using scratch image as base
FROM scratch
LABEL org.opencontainers.image.source https://github.com/mmorejon/knowing-scratch-image
# copy users file and app binary
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /go/bin/app /app
# set non-root user
USER scratchuser
# init command
ENTRYPOINT [ "/app" ]
