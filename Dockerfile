FROM ruby:2.6.2-alpine
MAINTAINER Pascal Havé <hpwxf@haveneer.com>

WORKDIR /travis-yml
RUN apk add --virtual build-dependencies build-base gcc git \
    && git clone https://github.com/travis-ci/travis-yml.git /travis-yml \
    && gem install bundler:2.0.1 \
    && `# gems are usually installed in /usr/local/bundle/gems/` \
    && `# this is overriden using --path /app` \
    && bundle install --deployment --path /app --without development test \
    && `# cleanup` \
    && apk del build-dependencies \
    && rm -rf /var/cache/apk/* \
    && rm -fr /travis-yml/.git \
    && find /app/ -name "*.c" -delete \
    && find /app/ -name "*.o" -delete \
    && rm -fr /usr/local/bundle/cache/ /app/ruby/2.6.0/cache/ \
    && rm -fr ~/.bundle ~/.gem

USER nobody

EXPOSE 9292
# Default rackup does not allow public connections
## ENTRYPOINT ["bundle","exec","rackup"]
# use directly puma command (cf https://github.com/puma/puma)
ENTRYPOINT bundle exec puma -t 1:2 -p 9292 -e development