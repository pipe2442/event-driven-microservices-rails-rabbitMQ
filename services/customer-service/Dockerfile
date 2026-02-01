FROM ruby:3.4.2

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

COPY bin/docker-entrypoint /usr/bin/docker-entrypoint
RUN chmod +x /usr/bin/docker-entrypoint

EXPOSE 3001

ENTRYPOINT ["docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3001"]
