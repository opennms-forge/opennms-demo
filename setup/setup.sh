#!/bin/bash
OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=admin

curl -v -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @foreign-sources.xml \
     http://${OPENNMS_HOST}:8980/opennms/rest/foreignSources

curl -v -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @demo-environment.xml \
     http://${OPENNMS_HOST}:8980/opennms/rest/requisitions

curl -v -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X PUT \
     http://${OPENNMS_HOST}:8980/opennms/rest/requisitions/demo-environment/import

# Delete existing graph before trying a new one
curl -v -u ${OPENNMS_USER}:${OPENNMS_PASS} \
    -X DELETE \
    http://${OPENNMS_HOST}:8980/opennms/rest/graphml/fosdem2017
sleep 5
curl -v -u ${OPENNMS_USER}:${OPENNMS_PASS} \
    -X POST \
    -H "Content-Type: application/xml" \
    -d @topology.xml \
    http://${OPENNMS_HOST}:8980/opennms/rest/graphml/fosdem2017