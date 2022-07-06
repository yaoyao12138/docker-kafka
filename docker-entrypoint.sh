#!/usr/bin/env bash

set -o allexport

: "${KAFKA_JVM_PERFORMANCE_OPTS:=-server -XX:MetaspaceSize=96m -XX:+UseG1GC -XX:G1HeapRegionSize=16M -XX:MaxGCPauseMillis=20 -XX:MinMetaspaceFreeRatio=50 -XX:MaxMetaspaceFreeRatio=80 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -Djava.awt.headless=true}"


if [[ "${FIPS_MODE}" = "true" ]]; then
  echo "INFO: Running in FIPS approved-only mode (org.bouncycastle.fips.approved_only=true)"
  KAFKA_JVM_PERFORMANCE_OPTS="${KAFKA_JVM_PERFORMANCE_OPTS} -Dorg.bouncycastle.fips.approved_only=true -Djava.security.properties=/etc/instana/kafka/java.security.bcfips"
else
  KAFKA_OPTS="-Dcom.redhat.fips=false ${KAFKA_OPTS}"
fi

set +o allexport

main() {

  echo "Starting Kafka..."
  exec kafka-server-start.sh ${KAFKA_HOME}/config/server.properties "$@"
}

main "$@"
