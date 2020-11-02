#!/bin/bash
OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_PORT=8980

GRAYLOG_HOST=localhost
GRAYLOG_USER=admin
GRAYLOG_PASS=admin
GRAYLOG_PORT=9000

# set -x

echo -n "Create Graylog input source for OpenNMS logging    ... "
curl -s -u ${GRAYLOG_USER}:${GRAYLOG_PASS} \
     -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d @graylog2-input.json \
     http://${GRAYLOG_HOST}:${GRAYLOG_PORT}/api/system/inputs
echo " DONE"

echo -n "Enable logging to Graylog2                         ... "
patch log4j2.xml < ../setup/enable-graylog.patch
echo "DONE"

echo -n "Create Requisition                                 ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @graylog-server.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/requisitions
echo "DONE"

echo -n "Import requisition for demo environment            ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X PUT \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/requisitions/graylog-server/import
echo "DONE"


