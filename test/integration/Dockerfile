ARG RUBY_VERSION=3.3

FROM ruby:$RUBY_VERSION

ARG REDMINE_BRANCH_NAME=master

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    sudo build-essential git gsfonts libsqlite3-dev \
    ;\
    rm -rf /var/lib/apt/lists/*

COPY test/integration/docker/*.sh .

RUN git config --global user.email "dev@example.com" && \
    git config --global user.name "dev"

#
# Directory to place the source code of rexer.
# Used to build and install the gem file of rexer.
#
RUN mkdir /rexer-src && \
    git config --global safe.directory /rexer-src

#
# Pseudo remote repositories for test plugins and themes
#
WORKDIR /git-server-repos
RUN git init --bare plugin_a.git
RUN git init --bare plugin_b.git
RUN git init --bare theme_a.git

#
# Local repositories to maintain test plugins and themes
#
WORKDIR /git-local-repos
COPY test/integration/docker/plugin_a plugin_a
COPY test/integration/docker/plugin_b plugin_b
COPY test/integration/docker/theme_a theme_a

# Plugin A
WORKDIR /git-local-repos/plugin_a
RUN git init && \
    git remote add origin /git-server-repos/plugin_a.git && \
    git add . && git commit -m "commit" && git push origin master && \
    git tag -a v0.1.0 -m "v0.1.0" && git push origin v0.1.0 && \
    git switch -c stable && git push origin stable
# Plugin B
WORKDIR /git-local-repos/plugin_b
RUN git init && \
    git remote add origin /git-server-repos/plugin_b.git && \
    git add . && git commit -m "commit" && git push origin master && \
    git tag -a v0.1.0 -m "v0.1.0" && git push origin v0.1.0 && \
    git switch -c stable && git push origin stable
# Theme A
WORKDIR /git-local-repos/theme_a
RUN git init && \
    git remote add origin /git-server-repos/theme_a.git && \
    git add . && git commit -m "commit" && git push origin master

#
# Redmine
#
WORKDIR /redmine
RUN git clone -b $REDMINE_BRANCH_NAME --depth 1 https://github.com/redmine/redmine.git .
COPY test/integration/docker/database.yml config/database.yml

# Directory for the bundle cache
RUN mkdir /redmine-bundle
VOLUME /redmine-bundle
ENV BUNDLE_PATH=/redmine-bundle

# Definition file
COPY test/integration/docker/extensions.rb .extensions.rb

RUN bundle install && bin/rails db:prepare

CMD ["/boot.sh"]
