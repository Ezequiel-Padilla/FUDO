FROM ruby:3.1

RUN apt-get update && apt-get install -y postgresql-client

WORKDIR /app
COPY Gemfile* ./
RUN gem install bundler && bundle install

COPY . .

EXPOSE 9292

CMD ["sh", "-c", "ruby db/migrate.rb && ruby db/seeds.rb && rackup -o 0.0.0.0 -p 9292"]
