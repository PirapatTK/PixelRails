# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-alpine AS base

# Rails app lives here
WORKDIR /rails

# Install required dependencies
RUN apk add --no-cache \
    build-base \
    git \
    libvips-dev \
    nodejs \
    yarn \
    postgresql-dev \
    tzdata

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Install application gems
# COPY Gemfile Gemfile.lock ./
# RUN bundle install && \
#     rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
#     bundle exec bootsnap precompile --gemfile

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=4 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# Final stage for app image
FROM base

# Install production dependencies
RUN apk add --no-cache libvips libpq postgresql-client

# Copy built application artifacts from the build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run as non-root user for security
RUN adduser -D -h /home/rails rails && \
    chown -R rails:rails /rails
USER rails

# Expose port 3000 for Rails server
EXPOSE 3000

# Entrypoint for handling database migrations and other prep
ENTRYPOINT ["./bin/docker-entrypoint"]

# Default command to start Rails server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
