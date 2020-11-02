#!/bin/bash
OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_PORT=8980

GRAYLOG_HOST=localhost
GRAYLOG_USER=admin
GRAYLOG_PASS=admin
GRAYLOG_PORT=9000

GRAFANA_HOST=localhost
GRAFANA_PORT=3000
GRAFANA_USER=admin
GRAFANA_PASS=mysecret

# set -x

echo -n "Ensure the ReST API is running before setup        "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:8980); do
    printf '.'
    sleep 2
done
echo " DONE"

# Change to project root directory
cd ..

echo -n "Create Minion user                                 ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @setup/minion-user.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/users
echo "DONE"

echo -n "Create user on Minion for ReST API and HTTP broker ... "
docker-compose exec minion-fulda-01 /opt/minion/bin/client "opennms:scv-set opennms.http minion minion"
docker-compose exec minion-fulda-01 /opt/minion/bin/client "opennms:scv-set opennms.broker minion minion"

#
# Change into OpenNMS config directory to apply configuration patches for Graylog and ActiveMQ for Minions
#
cd etc
echo -n "Enable listening for ActiveMQ on all interfaces    ... "
patch opennms-activemq.xml < ../setup/activemq-listen.patch
echo "DONE"

echo "Restart OpenNMS Horizon                            ... "
docker-compose stop opennms && docker-compose up -d

echo -n "Wait for web app to be ready                       "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:8980); do
    printf '.'
    sleep 2
done
echo " DONE"

cd ../setup
echo -n "Enable OpenNMS Helm plugin                   ... "
curl -s -u $GRAFANA_USER:$GRAFANA_PASS \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d '{"enabled": true}' \
     http://${GRAFANA_HOST}:${GRAFANA_PORT}/api/plugins/opennms-helm-app/settings
echo "DONE"

echo -n "Setup Grafana Entity Data Source             ... "
curl -s -u $GRAFANA_USER:$GRAFANA_PASS \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d @grafana-entity-ds.json \
     http://${GRAFANA_HOST}:${GRAFANA_PORT}/api/datasources
echo "DONE"

echo -n "Setup Grafana Flow Data Source               ... "
curl -s -u $GRAFANA_USER:$GRAFANA_PASS \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d @grafana-flow-ds.json \
     http://${GRAFANA_HOST}:${GRAFANA_PORT}/api/datasources
echo "DONE"

echo -n "Setup Grafana Performance Data Source        ... "
curl -s -u $GRAFANA_USER:$GRAFANA_PASS \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d @grafana-perf-ds.json \
     http://${GRAFANA_HOST}:${GRAFANA_PORT}/api/datasources
echo "DONE"
