#!/usr/bin/env bash

set -o allexport


if [[ "${FIPS_MODE}" = "true" ]]; then
  echo "INFO: Running in FIPS approved-only mode (org.bouncycastle.fips.approved_only=true)"
  KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -Dorg.bouncycastle.fips.approved_only=true -Djava.security.properties=/etc/instana/kafka/java.security.bcfips"
else
  KAFKA_OPTS="-Dcom.redhat.fips=false ${KAFKA_OPTS}"
fi

set +o allexport

main() {

  echo "Starting Kafka..."
  exec kafka-server-start.sh /etc/kafka/server.properties "$@"
}

main "$@"
