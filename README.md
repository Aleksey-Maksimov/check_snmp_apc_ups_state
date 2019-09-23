## About

**check_snmp_apc_ups_state** - Icinga Plugin Script (Check Command). 

It calculate APC UPS current state from SNMP data in upsBasicStateOutputState

Tested on **Debian GNU/Linux 9.11 (Stretch)** with **Icinga r2.10.5-1** 

Put here: /usr/lib/nagios/plugins/check_snmp_apc_ups_state.sh

PreReq: **snpmget** tool

## Usage

Options:

```
$ /usr/lib/nagios/plugins/check_snmp_apc_ups_state.sh [OPTIONS]

Option   GNU long option  Meaning
------   --------------   -------
-H      --hostname        Host name, IP Address
-P      --protocol        SNMP protocol version. Possible values: 1|2c|3
-C      --community       SNMPv1/2c community string for SNMP communication (for example,public)
-L      --seclevel        SNMPv3 securityLevel. Possible values: noAuthNoPriv|authNoPriv|authPriv
-a      --authproto       SNMPv3 auth proto. Possible values: MD5|SHA
-x      --privproto       SNMPv3 priv proto. Possible values: DES|AES
-U      --secname         SNMPv3 username
-A      --authpassword    SNMPv3 authentication password
-X      --privpasswd      SNMPv3 privacy password
-q      --help            Show this message
-v      --version         Print version information and exit

```
Example for all UPS types:

```
$ ./check_snmp_apc_ups_state.sh -H ups001.holding.com -P 2c -C public
```
Icinga Director integration manual (in Russian):

[Icinga плагин check_snmp_apc_ups_state для расширенного отслеживания аварийных состояний ИБП APC по данным, полученным по протоколу SNMP из параметра upsBasicStateOutputState](https://blog.it-kb.ru/2019/09/20/icinga-plugin-check_snmp_apc_ups_state-for-abnormal-conditions-monitoring-of-apc-ups-from-snmp-in-flags-from-upsbasicstateoutputstate/)
