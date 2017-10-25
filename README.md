# opennms-demo

OpenNMS demo environment with Docker and Docker Compose.

# Usage

Please adjust the directory for the [opennms/etc](https://github.com/opennms-forge/opennms-demo/blob/master/docker-compose.yml#L35) directory directory in the opennms-data container.

    ./etc:/opt/opennms/etc

HINT: The directory will be created in case it does not exist and will be initialized with a pristine _OpenNMS_ configuration.

Initialize the environment.

    git clone https://github.com/opennms-forge/opennms-demo.git
    cd opennms-demo
    docker-compose up -d

HINT: By default OpenNMS will use a automatically created daily snapshot of _OpenNMS_ and the tagged versions from [DockerHub](https://hub.docker.com/r/opennms/horizon-core-web/) can be used in the `docker-compose.yml` file.

# Bootstrap configuration

The demo environment comes with a Graylog2 service stack which allows you to get all logs from OpenNMS itself in easy accessible and searchable way.
Additionally the Minion requires some configuration to be able to communicate with OpenNMS Horizon.

In the setup directory you find the `configure.sh` script which does the following things:

* Configures ActiveMQ to listen on all interfaces
* Creates a user `minion` with password `minion` on OpenNMS Horizon with the `ROLE_MINION` and sets the same credentials on the Minion
* Enhances the log configuration from OpenNMS to forward all logs to Graylog2
* Creates a UDP Input on Graylog2 to be able to receive logs from OpenNMS Horizon

To feed the demo environment with data you can use the `demo-data.sh` script which does following things:

* Creates a foreign-source without detectors
* Creates a requisition with all nodes from the demo environment
* Uploades a GraphML topology which represents the network topology named _OpenNMS Demo_

Usage:

    cd setup
    ./configure.sh
    ./demo-data.sh

# Enabling LLDP

Forwarding _LLDPDU_ is not enabled by default on Linux _bridges_.
To enable _LLDPDU_ forwarding it is required to change the `group_fwd_mask` for a given _bridge_.

Using `docker-compose up -d` will create two additional bridges from this repository.
One bridge simulating a local area network and second bridge for a isolated network in a remote office.

To enable _LLDPDU_ forwarding it is required to identify the _bridge_ on the docker host system with:

    docker network ls

    a0713f06e511        lldp_branch         bridge              local
    2bde8ffcb81b        lldp_default        bridge              local
    bb562d6d9e30        lldp_local          bridge              local

The _NETWORK ID_ is part of the _bridge name_ on the host system.
To enable _LLDPDU_ forwarding for the _local_ network a _bridge_ is created.

    brctl show | grep bb562d6d9e30

    br-bb562d6d9e30		8000.0242deaee63c	no		veth067f1fa

The filter can be set with

    echo 16384 > /sys/class/net/br-bb562d6d9e30/bridge/group_fwd_mask

_LLDPDU_ forwarding is now enabled and works immediately.
