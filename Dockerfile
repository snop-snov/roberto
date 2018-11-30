FROM ruby:2.5.0

RUN gem install bundler rubygems-bundler

RUN mkdir -p /app
ADD . /app

WORKDIR /app/bot

RUN bundle install --jobs 3
RUN gem regenerate_binstubs

EXPOSE 8084
CMD rackup -o '0.0.0.0' -p 8084
