FROM ubuntu:14.04.5

RUN apt-get update
RUN apt-get install -y --force-yes apt-file
RUN apt-file update
RUN apt-get install -y --force-yes software-properties-common apt-transport-https
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-add-repository "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.9 main"
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
RUN apt-add-repository "deb https://dist.crystal-lang.org/apt crystal main"
RUN apt-get update

RUN apt-get install -y --force-yes ruby2.3
RUN gem install rake --no-document
RUN apt-get install -y --force-yes git make automake libtool pkg-config
RUN apt-get install -y --force-yes clang-3.9 libclang-3.9-dev llvm-3.9-dev
RUN apt-get install -y --force-yes libssl-dev libxml2-dev libyaml-dev libgmp-dev libevent-dev libpcre3-dev
RUN apt-get install -y --force-yes crystal
ENV PATH /opt/crystal/bin:$PATH
ENV CC clang-3.9
ENV CXX clang++-3.9

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/app"]
WORKDIR /app
ENTRYPOINT ["/bin/bash", "-l"]
