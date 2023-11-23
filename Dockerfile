# syntax=docker/dockerfile:1
FROM node:14-slim as base
RUN <<EOT
    set -e
    apt update
    apt install -y --no-install-recommends python2.7 unzip curl build-essential git ca-certificates
    mkdir /app
    chown -R node:node /app
    rm -rf /var/lib/apt/lists/*
EOT

FROM base as builder-site

WORKDIR /app
USER node
ENV PYTHON=python2.7

COPY --chown=node:node . /app/

RUN <<EOT
    set -e
    yarn
    yarn build
EOT


FROM base as builder-icons

WORKDIR /app
USER node
ENV PYTHON=python2.7

RUN <<EOT
    set -e
    curl -L -o icons.zip https://github.com/plone/pastanaga-icons/archive/refs/heads/master.zip
    unzip icons.zip
EOT

RUN <<EOT
    set -e
    cd pastanaga-icons-master/react-icons
    yarn
    yarn build
    mv build /app/public
EOT

FROM caddy:2.7-alpine

LABEL maintainer="kitconcept GmbH <info@kitconcept.io>" \
      org.label-schema.name="pastanaga-io" \
      org.label-schema.description="Pastanaga Public Site" \
      org.label-schema.vendor="kitconcept GmbH"

COPY --from=builder-site /app/public/ /usr/share/caddy/
COPY --from=builder-icons /app/public/ /usr/share/caddy/icons/
