FROM ruby:2.5.1
ENV BUNDLER_VERSION=2.0.1
RUN gem install bundler -v "${BUNDLER_VERSION}"
WORKDIR /workspace/enciclovida
COPY docker/development/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-e", "development", "-b", "0.0.0.0"]
