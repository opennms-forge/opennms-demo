#!/bin/bash
OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=admin

GRAYLOG_HOST=localhost
GRAYLOG_USER=admin
GRAYLOG_PASS=admin

# set -x

echo -n "Ensure the ReST API is running before setup        "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOME}:8980); do
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
     http://${OPENNMS_HOST}:8980/opennms/rest/users
echo "DONE"

echo -n "Create user on Minion for ReST API and HTTP broker ... "
docker-compose exec minion-fulda-01 /opt/minion/bin/client "scv:set opennms.http minion minion"
docker-compose exec minion-fulda-01 /opt/minion/bin/client "scv:set opennms.broker minion minion"

#
# Change into OpenNMS config directory to apply configuration patches for Graylog and ActiveMQ for Minions
#
cd etc
echo -n "Enable listening for ActiveMQ on all interfaces    ... "
patch opennms-activemq.xml < ../setup/activemq-listen.patch
echo "DONE"

echo -n "Enable logging to Graylog2                         ... "
patch log4j2.xml < ../setup/enable-graylog.patch
echo "DONE"

echo "Restart OpenNMS Horizon                            ... "
docker-compose stop opennms && docker-compose up -d

echo -n "Wait for web app to be ready                       "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOME}:8980); do
    printf '.'
    sleep 2
done
echo " DONE"

#
# Setup Demo data with foreign sources, requisitions and a topology
#
cd ../setup
echo -n "Create Graylog input source for OpenNMS logging    ... "
curl -s -u ${GRAYLOG_USER}:${GRAYLOG_PASS} \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d @graylog2-input.json \
     http://${GRAYLOG_HOST}:9000/api/system/inputs
echo " DONE"

echo -n "Create Foreign Sources                             ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @foreign-sources.xml \
     http://${OPENNMS_HOST}:8980/opennms/rest/foreignSources
echo "DONE"

echo -n "Create Requisition                                 ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @demo-environment.xml \
     http://${OPENNMS_HOST}:8980/opennms/rest/requisitions
echo "DONE"

echo -n "Import requisition for demo environment            ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X PUT \
     http://${OPENNMS_HOST}:8980/opennms/rest/requisitions/demo-environment/import
echo "DONE"

# Delete existing graph before trying a new one
echo -n "Delete existing demo GraphML topology if one exist ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
    -X DELETE \
    http://${OPENNMS_HOST}:8980/opennms/rest/graphml/fosdem2017
echo " DONE"
#sleep 5

echo -n "Create demo GraphML topology if one exist          ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
    -X POST \
    -H "Content-Type: application/xml" \
    -d @topology.xml \
    http://${OPENNMS_HOST}:8980/opennms/rest/graphml/fosdem2017
echo "DONE"
