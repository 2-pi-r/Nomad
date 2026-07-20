#!/bin/sh

BRIDGE=virbr0


do_brctl() {
    brctl "$@"
}

do_ifconfig() {
    ifconfig "$@"
}


# setup_bridge_nat "$BRIDGE"
WAN_IFACE=enp5s0
echo "Setting up NAT for $BRIDGE through $WAN_IFACE..."

sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null

sudo iptables -t nat -C POSTROUTING -o "$WAN_IFACE" -j MASQUERADE 2>/dev/null || \
sudo iptables -t nat -A POSTROUTING -o "$WAN_IFACE" -j MASQUERADE

sudo iptables -C FORWARD -i "$BRIDGE" -j ACCEPT 2>/dev/null || \
sudo iptables -A FORWARD -i "$BRIDGE" -j ACCEPT

sudo iptables -C FORWARD -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
sudo iptables -A FORWARD -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT


if test "$1" ; then
    echo "Adding interface $1 to bridge $BRIDGE..."
    do_ifconfig "$1" 0.0.0.0 up
    do_brctl addif "$BRIDGE" "$1"
fi
