FROM debian
MAINTAINER Hannes Elvemyr <hannes@elvemyrconsulting.se>

RUN apt-get update \
  && apt-get install -y rsync \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 873
VOLUME /volume
ADD ./run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]