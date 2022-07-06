# syntax=docker/dockerfile:1.4

ARG base_version=v0.5.0

FROM containers.instana.io/instana/product/jdk11:$base_version

ARG scala_version=2.13
ARG kafka_version=3.1.0
ARG kafka_distro_base_url=https://dlcdn.apache.org/kafka

ENV kafka_distro=kafka_$scala_version-$kafka_version.tgz
ENV kafka_distro_asc=$kafka_distro.asc

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka

RUN set -eux; \
        microdnf install -y gnupg wget gzip tar \
        && microdnf clean all; 

#WORKDIR /var/tmp

#RUN wget -q $kafka_distro_base_url/$kafka_version/$kafka_distro
#RUN wget -q $kafka_distro_base_url/$kafka_version/$kafka_distro_asc
#RUN wget -q $kafka_distro_base_url/KEYS

#RUN gpg --import KEYS
#RUN gpg --verify $kafka_distro_asc $kafka_distro

#RUN tar -xzf $kafka_distro 
#RUN rm -r kafka_$scala_version-$kafka_version/bin/windows

ARG bcfips_sha256="5f4d12234904c61c6f12d74b6cf4b3b5d32a2c3375d67367735be000bdd979ab"
ARG artifact_base="https://artifact-rnd.instana.io/artifactory/instana-private/org/bouncycastle"
RUN --mount=type=secret,id=artifactory_creds \
    export ARTIFACTORY_CREDS=jin.song:AKCp8k8PiN21K1uhAEp6oiD3DqqWgBTbgNBvpawE7civHJbVbJNdArc2hw95akB3qKi3pTAxT; \
    && mkdir -p ${KAFKA_HOME}\
    && wget -q $kafka_distro_base_url/$kafka_version/$kafka_distro \
    && wget -q $kafka_distro_base_url/$kafka_version/$kafka_distro_asc \
    && wget -q $kafka_distro_base_url/KEYS \
    && gpg --import KEYS \
    && gpg --verify $kafka_distro_asc $kafka_distro \
    && tar -xzf kafka.tgz -C ${KAFKA_HOME} --strip-components=1 \
    && rm kafka.tgz \
    && rm -rf ${KAFKA_HOME}/bin/windows \
    && curl -u "$ARTIFACTORY_CREDS" -fsSLo "/opt/instana/kafka/libs/bc-fips-$bcfips_version.jar" "$artifact_base/bc-fips/$bcfips_version/bc-fips-$bcfips_version.jar" \
    && sha256sum -c - <<< "$bcfips_sha256 /opt/instana/kafka/libs/bc-fips-$bcfips_version.jar"

#  export ARTIFACTORY_CREDS=$(< /run/secrets/artifactory_creds) \

#FROM eclipse-temurin:17.0.3_7-jre

#ARG scala_version=2.13
#ARG kafka_version=3.1.0

ENV PATH=${PATH}:${KAFKA_HOME}/bin

#RUN mkdir ${KAFKA_HOME} && apt-get update && apt-get install curl -y && apt-get clean
#RUN mkdir ${KAFKA_HOME}

#COPY /var/tmp/kafka_$scala_version-$kafka_version ${KAFKA_HOME}

RUN chmod a+x ${KAFKA_HOME}/bin/*.sh

WORKDIR $KAFKA_HOME
#COPY assets/ "$KAFKA_HOME"
COPY docker-entrypoint.sh /
#CMD ["kafka-server-start.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]
