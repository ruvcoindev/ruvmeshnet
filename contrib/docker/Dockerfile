FROM docker.io/golang:alpine as builder

COPY . /src
WORKDIR /src

ENV CGO_ENABLED=0

RUN apk add git && ./build && go build -o /src/genkeys cmd/genkeys/main.go

FROM docker.io/alpine

COPY --from=builder /src/ruvmeshnet /usr/bin/ruvmeshnet
COPY --from=builder /src/ruvmeshnetctl /usr/bin/ruvmeshnetctl
COPY --from=builder /src/genkeys /usr/bin/genkeys
COPY contrib/docker/entrypoint.sh /usr/bin/entrypoint.sh

# RUN addgroup -g 1000 -S ruvmeshnet-network \
#  && adduser -u 1000 -S -g 1000 --home /etc/ruvmeshnet-network ruvmeshnet-network
#
# USER ruvmeshnet-network
# TODO: Make running unprivileged work

VOLUME [ "/etc/ruvmeshnet-network" ]

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
