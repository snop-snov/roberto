FROM ruby:2.5.0

RUN gem install bundler rubygems-bundler

RUN mkdir -p /app
ADD . /app

WORKDIR /app

RUN bundle install --jobs 3
RUN gem regenerate_binstubs

EXPOSE 80
CMD rackup -o '0.0.0.0' -p 80
