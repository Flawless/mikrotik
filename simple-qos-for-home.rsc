#Set bandwidth of the interface
:local interfaceBandwidth 100M

#
/ip firewall mangle
# prio_1
    add chain=prerouting action=mark-packet new-packet-mark=prio_1 protocol=icmp
    add chain=prerouting action=mark-packet new-packet-mark=prio_1 protocol=tcp port=53
    add chain=prerouting action=mark-packet new-packet-mark=prio_1 protocol=udp port=53
    add chain=prerouting action=mark-packet new-packet-mark=prio_1 protocol=tcp tcp-flags=ack packet-size=0-123
# prio_2
    add chain=prerouting action=mark-packet new-packet-mark=prio_2 dscp=40                                     
    add chain=prerouting action=mark-packet new-packet-mark=prio_2 dscp=46
    add chain=prerouting action=mark-packet new-packet-mark=prio_2 protocol=udp port=5060,5061,10000-20000 src-address=10.10.10.10
    add chain=prerouting action=mark-packet new-packet-mark=prio_2 protocol=udp port=5060,5061,10000-20000 dst-address=10.10.10.10
# prio_3
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 protocol=tcp port=22
    add chain=prerouting action=mark-packet new-packet-mark=prio_3 protocol=tcp port=3724
# prio_4
    add chain=prerouting action=mark-packet new-packet-mark=prio_4 protocol=tcp port=3389
    add chain=prerouting action=mark-packet new-packet-mark=prio_4 protocol=tcp port=80,443

/queue tree add max-limit=$interfaceBandwidth name=QoS_global parent=global priority=1
:for indexA from=1 to=4 do={
   /queue tree add \ 
      name=( "prio_" . "$indexA" ) \
      parent=QoS_global \
      priority=($indexA) \
      queue=ethernet-default \
      packet-mark=("prio_" . $indexA) \
      comment=("Priority " . $indexA . " traffic")
}
/queue tree add name="prio_5" parent=QoS_global priority=5 queue=ethernet-default \
    packet-mark=no-mark comment="Priority 5 traffic"

/ip firewall mangle
# prio_1
    add chain=prerouting action=set-priority new-priority=7 protocol=icmp
    add chain=prerouting action=set-priority new-priority=7 protocol=tcp port=53
    add chain=prerouting action=set-priority new-priority=7 protocol=udp port=53
    add chain=prerouting action=set-priority new-priority=7 protocol=tcp tcp-flags=ack packet-size=0-123
# prio_2
    add chain=prerouting action=set-priority new-priority=6 dscp=40                                     
    add chain=prerouting action=set-priority new-priority=6 dscp=46
    add chain=prerouting action=set-priority new-priority=6 protocol=udp port=5060,5061,10000-20000 src-address=10.10.10.10
    add chain=prerouting action=set-priority new-priority=6 protocol=udp port=5060,5061,10000-20000 dst-address=10.10.10.10
# prio_3
    add chain=prerouting action=set-priority new-priority=5 protocol=tcp port=22
    add chain=prerouting action=set-priority new-priority=5 protocol=tcp port=3724
# prio_4
    add chain=prerouting action=set-priority new-priority=3 protocol=tcp port=3389
