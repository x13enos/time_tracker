FROM ruby:2.6.1-alpine

ENV PATH /root/.yarn/bin:$PATH

RUN apk add --no-cache bash git openssh build-base tzdata postgresql-dev

ENV RAILS_ROOT /var/www/time_tracker
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

ADD Gemfile* $RAILS_ROOT/
RUN gem install bundler && bundle install

ADD . $RAILS_ROOT
