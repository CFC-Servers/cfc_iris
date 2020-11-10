FROM ruby:2.7.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /iris-backend
RUN mkdir -p tmp/pids
WORKDIR /iris-backend
COPY Gemfile /iris-backend/Gemfile
COPY Gemfile.lock /iris-backend/Gemfile.lock
RUN NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install -j2
COPY . /iris-backend

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3115

# Start the main process.
CMD ["bundle", "exec", "puma", "-t", "5:5", "-p", "3115"]
