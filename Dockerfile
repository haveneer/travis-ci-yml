FROM ruby:2.6.2-alpine
MAINTAINER Pascal Havé <hpwxf@haveneer.com>
RUN apk add --no-cache --virtual build-dependencies \
        build-base \
        gcc \
        git
RUN git clone https://github.com/travis-ci/travis-yml.git /travis-yml
WORKDIR /travis-yml
RUN gem install bundler:2.0.1 && bundle install
RUN apk del build-dependencies \
    && rm -rf /var/cache/apk/*

EXPOSE 9292
# Default rackup does not allow public connections
#ENTRYPOINT ["bundle","exec","rackup"]
# https://github.com/puma/puma
ENTRYPOINT bundle exec puma -t 5:5 -p 9292 -e development