#!/bin/bash
sudo ip link set wlp11s0 up
sudo dhclient -6 -v wlp11s0 || echo "Failed to get IPv6 via DHCPv6"
