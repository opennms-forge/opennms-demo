#!/bin/bash
OPENNMS_HOST=192.168.99.100
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
