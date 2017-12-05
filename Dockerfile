FROM ruby:2.3.4
#FROM ruby:2.3.4-jessie

#COPY sources.list.template /etc/apt/sources.list

RUN apt-get update && apt-get install -y build-essential libpq-dev nodejs libqt4-dev libqtwebkit-dev

ENV INSTALL_PATH /boostr

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile.lock ./
COPY config/database.yml.example ./config/database.yml

RUN bundle install

COPY . .

COPY docker-entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
