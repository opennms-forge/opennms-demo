# opennms-demo
OpenNMS demo environment with Docker and Docker Compose

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
