ARG base_version=v0.5.0

FROM containers.instana.io/instana/product/jdk11:$base_version

ARG scala_version=2.13
ARG kafka_version=3.1.0
ARG kafka_distro_base_url=https://dlcdn.apache.org/kafka

ENV kafka_distro=kafka_$scala_version-$kafka_version.tgz
ENV kafka_distro_asc=$kafka_distro.asc

RUN apk add --no-cache gnupg

WORKDIR /var/tmp

RUN wget -q $kafka_distro_base_url/$kafka_version/$kafka_distro
RUN wget -q $kafka_distro_base_url/$kafka_version/$kafka_distro_asc
RUN wget -q $kafka_distro_base_url/KEYS

RUN gpg --import KEYS
RUN gpg --verify $kafka_distro_asc $kafka_distro

RUN tar -xzf $kafka_distro 
RUN rm -r kafka_$scala_version-$kafka_version/bin/windows


FROM eclipse-temurin:17.0.3_7-jre

ARG scala_version=2.13
ARG kafka_version=3.1.0

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka

ENV PATH=${PATH}:${KAFKA_HOME}/bin

#RUN mkdir ${KAFKA_HOME} && apt-get update && apt-get install curl -y && apt-get clean
RUN mkdir ${KAFKA_HOME}

COPY --from=kafka_dist /var/tmp/kafka_$scala_version-$kafka_version ${KAFKA_HOME}

RUN chmod a+x ${KAFKA_HOME}/bin/*.sh

#COPY assets/ "$KAFKA_HOME"
COPY docker-entrypoint.sh /
#CMD ["kafka-server-start.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]
