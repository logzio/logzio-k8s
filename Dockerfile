FROM fluent/fluentd-kubernetes-daemonset:v1.7-debian-logzio-1

USER root
WORKDIR /home/fluent

COPY Gemfile* /fluentd/
RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps libjemalloc1 \
 && bundle install --gemfile=/fluentd/Gemfile --path=/fluentd/vendor/bundle \
 && sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

# Copy configuration files
COPY ./conf/*.conf /fluentd/etc/

# Default values for fluent.conf
ENV LOGZIO_BUFFER_TYPE "file"
ENV LOGZIO_BUFFER_PATH "/var/log/fluentd-buffers/stackdriver.buffer"
ENV LOGZIO_OVERFLOW_ACTION "block"
ENV LOGZIO_CHUNK_LIMIT_SIZE "2M"
ENV LOGZIO_QUEUE_LIMIT_LENGTH "6"
ENV LOGZIO_FLUSH_INTERVAL "5s"
ENV LOGZIO_RETRY_MAX_INTERVAL "30"
ENV LOGZIO_RETRY_FOREVER "true"
ENV LOGZIO_FLUSH_THREAD_COUNT "2"

# Defaults value for system.conf
ENV LOGZIO_LOG_LEVEL "info"

