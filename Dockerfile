FROM --platform=linux/amd64 ruby:3.1

ENV BUNDLER_VERSION=2.5.23

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      build-essential \
      libpq-dev \
      default-libmysqlclient-dev \
      pkg-config && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v "${BUNDLER_VERSION}"

WORKDIR /workspace/enciclovida

COPY docker/development/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["bundle", "exec", "rails", "server", "-e", "development", "-b", "0.0.0.0"]