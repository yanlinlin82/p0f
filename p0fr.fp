#
# p0f - RST+ signatures
# ---------------------
#
# .-------------------------------------------------------------------------.
# | The purpose of this file is to cover signatures for reset packets       |
# | (RST and RST+ACK). This mode of operation can be enabled with -A option |
# | and is considered to be least accurate. Please refer to p0f.fp for more |
# | information on the metrics used and for a guide on adding new entries   |
# | to this file. This database is looking for a caring maintainer.         |
# `-------------------------------------------------------------------------'
#
# (C) Copyright 2000-2003 by Michal Zalewski <lcamtuf@coredump.cx>
#
# Submit all additions to the authors. Read p0f.fp before adding any
# signatures. Run p0f -R -C after making any modifications. This file is
# NOT compatible with SYN or SYN+ACK modes. Use only with -R option.
#
#
# IMPORTANT INFORMATION ABOUT THE INTERDEPENDENCY OF SYNs AND RST+ACKs
# --------------------------------------------------------------------
#
# Some silly systems may copy WSS from the SYN packet you've sent,
# in which case, you need to wildcard the value. Use test/sendsyn.c for
# "connection refused" and test/sendack.c for "connection dropped" signatures
# - both tools use a distinct WSS of 12345, which is an easy way to tell
# if WSS should be wildcarded.
#
# IMPORTANT INFORMATION ABOUT COMMON IMPLEMENTATION FLAWS
# -------------------------------------------------------
#
# There are several types of RST packets you will surely encounter.
# Some systems, including most reputable ones, are severily brain-damaged
# and generate some illegal combinations from time to time. This is WAY
# more common than with other packet types, because a broken RST does not
# have any immediately noticable consequences; besides, the RFC793 is fairly
# difficult to comprehend when it comes to this type of responses.
#
# P0f will give you a hint on new RST signatures, but it is your duty to
# diagnose the problem and append the proper description when adding the
# signature. Below is a list of valid and invalid states:
#
# - "Connection refused" message: this is a RST+ACK packet, SEQ number
#   set to zero, ACK number non-zero. This is a valid response and
#   is denoted by p0f as "refused" (quirk combination: K, 0, A).
#
#   There are some very cases when this is incorrectly sent in response
#   to an unexpected ACK packet.
#
# - Illegal combination: RST+ACK packet, SEQ number set to zero, ACK
#   number zero. This is denoted by p0f as "invalid-K0" (quirk combination:
#   K and 0, no A). 
#
# - Illegal combination: RST+ACK, SEQ number non-zero, ACK number zero
#   or non-zero. This is denoted by p0f as "invalid-K" and
#   "invalid-KA", respectively (quirk combinations, K, sometimes A, no 0).
#
#   This combination is frequently generated by Cisco routers in certain
#   configurations in response to ACK (!). Brain dead, by all means, and
#   usually a result of (incorrectly) setting ACK flag on a valid RST packet.
#
# - "Connection dropped": RST, sequence number non-zero, ACK zero or
#   non-zero. This is denoted as "dropped" and "dropped 2" respectively
#   (quirk combinations: no K, sometimes A, no 0). While the ACK value should
#   be zeroed, it is not strictly against the RFC, and some systems either
#   leak memory there or set it to the value of SEQ.
#
#   The latter variant, with non-zero ACK, is particularly common on
#   Windows.
#
# - Ilegal combination: RST, SEQ number zero, ACK zero or non-zero. 
#   Denoted as "invalid-0" and "invalid-0A". Obviously incorrect, and
#   will not have the desired effect.
#
# Ok. That's it. RFC793 does not get much respect nowadays.
#
# IMPORTANT INFORMATION ABOUT DIFFERENCES IN COMPARISON TO p0f.fp:
# ----------------------------------------------------------------
#
# - Packet size may be wildcarded. The meaning of wildcard is, however,
#   hardcoded as 'size > PACKET_BIG' (defined as 100 in config.h). This is
#   because some stupid devices (including Ciscos) tend to send back RST
#   packets quoting anything you have sent them in ACK packet previously.
#   Use sparingly, only if -X confirms the device actually bounces back
#   whatever you send.
#
# - A new quirk, 'K', is introduced to denote RST+ACK packets (as opposed
#   to plain RST). This quirk is only compatible with this mode.
#
# - A new quirk, 'Q', is used to denote SEQ number equal to ACK number.
#   This happens from time to time in RST and RST+ACK packets, but 
#   is practically unheard of in other modes.
#
# - A new quirk, '0', is used to denote packets with SEQ number set to 0.
#   This happens on some RSTs, and is once again unheard of in other modes.
#
# - 'D' quirk is not a bug; some devices send verbose text messages
#   describing why a connection got dropped; it's actually suggested
#   by RFC1122. Of course, some systems have their own standards, and
#   put all kinds of crap in their RST responses (including FreeBSD and
#   Cisco). Use -X to examine those values.
#
# - 'A' and 'T' quirks are not an anomaly in certain cases for the reasons
#   described in p0fa.fp.
#

################################
# Connection refused - RST+ACK #
################################

0:255:0:40:.:K0A:Linux:2.0/2.2 (refused)
0:64:1:40:.:K0A:FreeBSD:4.8 (refused)
0:64:1:40:.:K0ZA:Linux:recent 2.4 (refused)
0:128:0:40:.:K0A:Windows:XP/2000 (refused)
0:128:0:40:.:K0UA:-Windows:XP/2000 while browsing (refused)

######################################
# Connection dropped / timeout - RST #
######################################

0:64:1:40:.:.:FreeBSD:4.8 (dropped)
0:255:0:40:.:.:Linux:2.0/2.2 or IOS 12.x (dropped)
0:64:1:40:.:Z:Linux:recent 2.4 (dropped)
0:255:1:40:.:Z:Linux:early 2.4 (dropped)
0:32:0:40:.:.:Xylan:OmniSwitch / Linksys WAP11 AP (dropped)
0:64:1:40:.:U:NetIron:load balancer (dropped)

0:128:1:40:.:QA:Windows:XP/2000 (dropped 2)
0:128:1:40:.:A:-Windows:XP/2000 while browsing (1) (dropped 2)
0:128:1:40:.:QUA:-Windows:XP/2000 while browsing (2) (dropped 2)
0:128:1:40:.:UA:-Windows:XP/2000 while browsing a lot (dropped 2)
0:128:1:40:.:.:@Windows:98 (?) (dropped)

0:64:0:40:.:A:Ascend:TAOS or BayTech (dropped 2)

*:255:0:40:.:QA:Cisco:LocalDirector (dropped 2)

0:64:1:40:.:A:Hasbani:WindWeb (dropped 2)
S23:241:1:40:.:.:Solaris:2.5 (dropped)

#######################################################
# Connection dropped / timeout - RST with description #
#######################################################

0:255:1:58:.:D:MacOS:9.x "No TCP/No listener" (seldom SunOS 5.x) (dropped)
0:255:1:53:.:D:MacOS:8.5 "no tcp, reset" (dropped)
0:255:1:65:.:D:MacOS:X "tcp_close, during connect" (dropped)
0:255:1:54:.:D:MacOS:X "tcp_disconnect" (dropped)
0:255:1:62:.:D:HP/UX:? "tcp_fin_wait_2_timeout" (dropped)
32768:255:1:54:.:D:MacOS:8.5 "tcp_disconnect" (dropped)
0:255:1:63:.:D:@Unknown: "Go away" device (dropped)

0:255:0:62:.:D:SunOS:5.x "new data when detached" (1) (dropped)
32768:255:1:62:.:D:SunOS:5.x "new data when detached" (2) (dropped)
0:255:1:67:.:D:SunOS:5.x "tcp_lift_anchor, can't wait" (dropped)

0:255:0:46:.:D:HP/UX:11.00 "No TCP" (dropped)

# More obscure ones:
# 648:255:1:54:.:D:MacOS:??? "tcp_disconnect" (dropped)
# 0:45:1:53:.:D:MacOS:7.x "no tcp, reset" (dropped)

##############################################
# Connection dropped / timeout - broken RSTs #
##############################################

S12:255:1:58:.:KAD:Solaris:2.x "tcp_disconnect" (dropped, lame)
S43:64:1:40:.:KA:AOL:proxy (dropped, lame)
*:64:1:40:.:KA:FreeBSD:4.8 (dropped, lame)
*:64:1:52:N,N,T:KAT:Linux:2.4 (?) (dropped, lame)
0:255:0:40:.:KAF:3Com:SuperStack II (dropped, lame)
*:255:0:40:.:KA:Intel:Netport print server (dropped, lame)
*:150:0:40:.:KA:Linksys:BEF router (dropped, lame)

*:32:0:44:.:KZD:@NetWare:??? "ehnc" (dropped, lame)
0:64:0:40:.:KQ0:BayTech:RPC-3 telnet host (dropped, lame)

#############################################
# Connection dropped / timeout - extra data #
#############################################

*:255:0:*:.:KAD:Cisco:IOS/PIX NAT + data (1) (dropped, lame)
0:255:0:*:.:D:Windows:NT 4.0 SP6a + data (dropped)
0:255:0:*:.:K0AD:Isolation:Infocrypt accelerator + data (dropped, lame)

*:255:0:*:.:AD:Cisco:IOS/PIX NAT + data (2) (dropped)

*:64:1:*:N,N,T:KATD:Linux:2.4 (?) + data (dropped, lame)
*:64:1:*:.:KAD:FreeBSD:4.8 + data (dropped, lame)



