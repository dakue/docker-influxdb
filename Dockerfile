FROM debian:jessie
MAINTAINER Daniel Kuehne <dkhmailto@googlemail.com>

ENV INFLUXDB_VERSION 0.9.4
ENV GOSU_VERSION 1.4
ENV ENVPLATE_VERSION 0.0.8
ENV TZ Europe/Berlin

RUN echo $TZ > /etc/timezone && \
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata

RUN apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl ca-certificates && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/

RUN curl -sSL https://s3.amazonaws.com/influxdb/influxdb_${INFLUXDB_VERSION}_amd64.deb -o /tmp/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
  dpkg -i /tmp/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
  rm /tmp/influxdb_${INFLUXDB_VERSION}_amd64.deb

RUN curl -sSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" -o /usr/local/bin/gosu && \
  chmod +x /usr/local/bin/gosu && \
  curl -ssL "https://github.com/kreuzwerker/envplate/releases/download/v${ENVPLATE_VERSION}/ep-linux" -o /usr/local/bin/ep && \
  chmod +x /usr/local/bin/ep && \
  ln -s /usr/local/bin/ep /usr/local/bin/envplate

COPY influxdb.conf /etc/influxdb/config.toml

RUN mkdir -p /var/run/influxdb && \
  chown -R influxdb:influxdb /var/run/influxdb && \
  mkdir -p /var/lib/influxdb && \
  chown -R influxdb:influxdb /var/lib/influxdb

VOLUME /var/lib/influxdb

COPY setup.sh /
RUN chmod +x /setup.sh

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 2003 4242 8083 8086 8088 25826

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["influxdb"]
