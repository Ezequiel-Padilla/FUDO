FROM ruby:3.1

WORKDIR /app
COPY Gemfile* ./
RUN gem install bundler && bundle install

COPY .. .

EXPOSE 9292
CMD ["rackup", "-o", "0.0.0.0", "-p", "9292"]
