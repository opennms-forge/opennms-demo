#!/bin/bash
OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_PORT=8980

# set -x

echo -n "Ensure the ReST API is running before setup        "
until $(curl -L --output /dev/null --silent --head --fail http://${OPENNMS_HOST}:8980); do
    printf '.'
    sleep 2
done
echo "    DONE"

#
# Setup Demo data with foreign sources, requisitions and a topology
#
echo -n "Create Foreign Sources                             ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @foreign-sources.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/foreignSources
echo "DONE"

echo -n "Create Requisition                                 ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X POST \
     -H "Content-Type: application/xml" \
     -H "Accept: application/xml" \
     -d @demo-environment.xml \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/requisitions
echo "DONE"

echo -n "Import requisition for demo environment            ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
     -X PUT \
     http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/requisitions/demo-environment/import
echo "DONE"

# Delete existing graph before trying a new one
echo -n "Delete existing demo GraphML topology if one exist ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
    -X DELETE \
    http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/graphml/opennms-demo
echo "DONE"
#sleep 5

echo -n "Create demo GraphML topology if one exist          ... "
curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
    -X POST \
    -H "Content-Type: application/xml" \
    -d @topology.xml \
    http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/graphml/opennms-demo
echo "DONE"
