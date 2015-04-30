FROM centos:7 
MAINTAINER Christoph Görn <goern@b4mad.net>

LABEL License=MIT

USER root

############################################################
# Setup environment variables
############################################################

ENV WWW_DIR /var/www/html
ENV SOURCE_DIR /tmp/source
ENV START_SCRIPT /root/start-apache.sh

RUN mkdir -pv $WWW_DIR

############################################################
# Install and configure webserver software
############################################################

RUN yum install -y --setopt=tsflags=nodocs epel-release && \
    yum install -y --setopt=tsflags=nodocs httpd git nodejs npm make libpng-devel && \
# nodejs-legacy
    yum update -y && \
    yum clean all 
#      libapache2-mod-auth-kerb

############################################################
# This adds everything we need to the build root except those
# element that are matched by .dockerignore.
# We explicitly list every directory and file that is involved
# in the build process but. All config files (like nginx) are
# not listed to speed up the build process. 
############################################################

# Create dirs
RUN mkdir -p $SOURCE_DIR/dist $SOURCE_DIR/app $SOURCE_DIR/test $SOURCE_DIR/.git

# Add dirs
ADD app $SOURCE_DIR/app
ADD test $SOURCE_DIR/test

# Dot files
ADD .jshintrc $SOURCE_DIR/
ADD .bowerrc $SOURCE_DIR/
ADD .editorconfig $SOURCE_DIR/
ADD .travis.yml $SOURCE_DIR/

# Other files
ADD bower.json $SOURCE_DIR/
ADD Gruntfile.js $SOURCE_DIR/
ADD LICENSE $SOURCE_DIR/
ADD package.json $SOURCE_DIR/
ADD README.md $SOURCE_DIR/

# Add Git version information to it's own json file app-version.json
ADD .git/HEAD $SOURCE_DIR/.git/HEAD
ADD .git/refs $SOURCE_DIR/.git/refs
RUN cd $SOURCE_DIR && \
    export GITREF=$(cat .git/HEAD | cut -d" " -f2) && \
    export GITSHA1=$(cat .git/$GITREF) && \
    echo "{\"git\": {\"sha1\": \"$GITSHA1\", \"ref\": \"$GITREF\"}}" > $WWW_DIR/app-version.json && \
    cd $SOURCE_DIR && \
    rm -rf $SOURCE_DIR/.git

############################################################
# This is written so compact, to reduce the size of the
# final container and its layers. We have to install build
# dependencies, build the app, deploy the app to the web
# root, remove the source code, and then uninstall the build
# dependencies. When packed into one RUN instruction, the
# resulting layer will hopefully only be comprised of the
# installed app artifacts.
############################################################

RUN git config --global url."https://".insteadOf git:// && \
    cd $SOURCE_DIR && \
    npm install && \
    node_modules/bower/bin/bower install --allow-root && \
    node_modules/grunt-cli/bin/grunt build --allow-root && \
    cp -rf $SOURCE_DIR/dist/* $WWW_DIR && \
    rm -rf $SOURCE_DIR && \
#    apt-get -y --auto-remove purge git nodejs nodejs-legacy npm && \
#    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

############################################################
# Add and enable the apache site and disable all other sites
############################################################

ADD apache-site.conf /etc/httpd/conf.d/docker-registry-frontend.conf

ADD start-apache.sh $START_SCRIPT
RUN chmod +x $START_SCRIPT

ENV APACHE_RUN_USER apache
ENV APACHE_RUN_GROUP apache 
ENV APACHE_LOG_DIR /var/log/httpd

# Let people know how this was built
ADD Dockerfile /root/Dockerfile

# Exposed ports
EXPOSE 80 443

VOLUME ["/etc/httpd/server.crt", "/etc/httpd/server.key"]

CMD $START_SCRIPT
