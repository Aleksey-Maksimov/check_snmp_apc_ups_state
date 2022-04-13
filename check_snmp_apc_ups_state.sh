#!/bin/bash
#
# Icinga Plugin Script (Check Command). It calculate APC UPS current state from SNMP data in upsBasicStateOutputState
# Aleksey Maksimov <aleksey.maksimov@it-kb.ru>
# Tested on Debian GNU/Linux 9.11 (Stretch) with Icinga r2.10.5-1 
# Put here: /usr/lib/nagios/plugins/check_snmp_apc_ups_state.sh
# Usage example:
# ./check_snmp_apc_ups_state.sh -H ups-nmc-01.holding.com -P 2c -C public
#
PLUGIN_NAME="Icinga Plugin Check Command to calculate APC UPS current state (from SNMP data)"
PLUGIN_VERSION="2019.09.16"
PRINTINFO=`printf "\n%s, version %s\n \n" "$PLUGIN_NAME" "$PLUGIN_VERSION"`
#
# Exit codes
#
codeOK=0
codeWARNING=1
codeCRITICAL=2
codeUNKNOWN=3
#
# OID
#
checkOID="1.3.6.1.4.1.318.1.1.1.11.1.1.0"
#
Usage() {
  echo "$PRINTINFO"
  echo "Usage: $0 [OPTIONS]

Option   GNU long option        Meaning
------   ---------------	-------
 -H      --hostname		Host name, IP Address
 -P      --protocol		SNMP protocol version. Possible values: 1|2c|3
 -C      --community		SNMPv1/2c community string for SNMP communication (for example,"public")
 -L      --seclevel		SNMPv3 securityLevel. Possible values: noAuthNoPriv|authNoPriv|authPriv
 -a      --authproto		SNMPv3 auth proto. Possible values: MD5|SHA
 -x      --privproto		SNMPv3 priv proto. Possible values: DES|AES
 -U      --secname		SNMPv3 username
 -A      --authpassword		SNMPv3 authentication password
 -X      --privpasswd		SNMPv3 privacy password
 -q      --help			Show this message
 -v      --version		Print version information and exit

"
}
#
# Parse arguments
#
if [ -z $1 ]; then
    Usage; exit $codeUNKNOWN;
fi
#
OPTS=`getopt -o H:P:C:L:a:x:U:A:X:qv -l hostname:,protocol:,community:,seclevel:,authproto:,privproto:,secname:,authpassword:,privpasswd:,help,version -- "$@"`
eval set -- "$OPTS"
while true; do
   case $1 in
     -H|--hostname) HOSTNAME=$2 ; shift 2 ;;
     -P|--protocol)
        case "$2" in
        "1"|"2c"|"3") PROTOCOL=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use '1' or '2c' or '3'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;
     -C|--community)     COMMUNITY=$2 ; shift 2 ;;
     -L|--seclevel)
        case "$2" in
        "noAuthNoPriv"|"authNoPriv"|"authPriv") v3SECLEVEL=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use 'noAuthNoPriv' or 'authNoPriv' or 'authPriv'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;
     -a|--authproto)
        case "$2" in
        "MD5"|"SHA") v3AUTHPROTO=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use 'MD5' or 'SHA'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;
     -x|--privproto)
        case "$2" in
        "DES"|"AES") v3PRIVPROTO=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use 'DES' or 'AES'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;                    
     -U|--secname)       v3SECNAME=$2 ; shift 2 ;;
     -A|--authpassword)  v3AUTHPWD=$2 ; shift 2 ;;
     -X|--privpasswd)    v3PRIVPWD=$2 ; shift 2 ;;
     -q|--help)          Usage ; exit $codeOK ;;
     -v|--version)       echo "$PRINTINFO" ; exit $codeOK ;;
     --) shift ; break ;;
     *)  Usage ; exit $codeUNKNOWN ;;
   esac 
done
#
# Set SNMP connection paramaters 
#
vCS=$( echo " -O qvn -v $PROTOCOL" )
if [ "$PROTOCOL" = "1" ] || [ "$PROTOCOL" = "2c" ]
then
   vCS=$vCS$( echo " -c $COMMUNITY" );
elif [ "$PROTOCOL" = "3" ]
then
   vCS=$vCS$( echo " -l $v3SECLEVEL" );
   vCS=$vCS$( echo " -a $v3AUTHPROTO" );
   vCS=$vCS$( echo " -x $v3PRIVPROTO" );
   vCS=$vCS$( echo " -A $v3AUTHPWD" );
   vCS=$vCS$( echo " -X $v3PRIVPWD" );
   vCS=$vCS$( echo " -u $v3SECNAME" );
fi
#
# Calculate APC UPS State
#
vOIDOut=$( snmpget $vCS $HOSTNAME $checkOID )
vOIDOut=$( echo $vOIDOut | tr -d '"' )
if [ ${#vOIDOut} -ne 64 ]; then 
   echo "The string length obtained from the SNMP parameter 'upsBasicStateOutputState' is not equal to 64 characters. So we cannot parse the data."
   exit $codeUNKNOWN
fi

declare -a vFlags=(
"Flag 01: Abnormal Condition Present" 
"Flag 02: On Battery" 
"Flag 03: Low Battery"
"Flag 04: On Line" 
"Flag 05: Replace Battery"  
"Flag 06: Serial Communication Established"  
"Flag 07: AVR Boost Active"  
"Flag 08: AVR Trim Active"  
"Flag 09: Overload"  
"Flag 10: Runtime Calibration" 
"Flag 11: Batteries Discharged" 
"Flag 12: Manual Bypass" 
"Flag 13: Software Bypass" 
"Flag 14: In Bypass due to Internal Fault" 
"Flag 15: In Bypass due to Supply Failure" 
"Flag 16: In Bypass due to Fan Failure" 
"Flag 17: Sleeping on a Timer" 
"Flag 18: Sleeping until Utility Power Returns" 
"Flag 19: On" 
"Flag 20: Rebooting" 
"Flag 21: Battery Communication Lost" 
"Flag 22: Graceful Shutdown Initiated" 
"Flag 23: Smart Boost or Smart Trim Fault" 
"Flag 24: Bad Output Voltage" 
"Flag 25: Battery Charger Failure" 
"Flag 26: High Battery Temperature" 
"Flag 27: Warning Battery Temperature" 
"Flag 28: Critical Battery Temperature" 
"Flag 29: Self Test In Progress" 
"Flag 30: Low Battery / On Battery" 
"Flag 31: Graceful Shutdown Issued by Upstream Device" 
"Flag 32: Graceful Shutdown Issued by Downstream Device" 
"Flag 33: No Batteries Attached" 
"Flag 34: Synchronized Command is in Progress" 
"Flag 35: Synchronized Sleeping Command is in Progress" 
"Flag 36: Synchronized Rebooting Command is in Progress" 
"Flag 37: Inverter DC Imbalance" 
"Flag 38: Transfer Relay Failure" 
"Flag 39: Shutdown or Unable to Transfer" 
"Flag 40: Low Battery Shutdown" 
"Flag 41: Electronic Unit Fan Failure" 
"Flag 42: Main Relay Failure" 
"Flag 43: Bypass Relay Failure" 
"Flag 44: Temporary Bypass" 
"Flag 45: High Internal Temperature" 
"Flag 46: Battery Temperature Sensor Fault" 
"Flag 47: Input Out of Range for Bypass" 
"Flag 48: DC Bus Overvoltage" 
"Flag 49: PFC Failure" 
"Flag 50: Critical Hardware Fault" 
"Flag 51: Green Mode/ECO Mode" 
"Flag 52: Hot Standby" 
"Flag 53: Emergency Power Off (EPO) Activated" 
"Flag 54: Load Alarm Violation" 
"Flag 55: Bypass Phase Fault" 
"Flag 56: UPS Internal Communication Failure" 
"Flag 57: Efficiency Booster Mode" 
"Flag 58: Off" 
"Flag 59: Standby" 
"Flag 60: Minor or Environment Alarm") 


vFlag1=$( echo $vOIDOut |  awk '{print substr($0,0,1)}' )

vFlagsStr=""
vIndex=0
for vFlag in "${vFlags[@]}"; do

  vFlagN=$( echo ${vOIDOut:vIndex:1} )
  if [ "$vFlagN" -eq "1" ]; then
	vFlagsStr=$vFlagsStr$( echo "\n${vFlag}" );
  fi
  let vIndex=${vIndex}+1
done

#
# Icinga Check Plugin output
#
if [ "$vFlag1" -eq "1" ]; then
    echo -e "APC UPS State CRITICAL \nCurrent active flags:$vFlagsStr"
    exit $codeCRITICAL
elif [ "$vFlag1" -eq "0" ]; then
    echo -e "APC UPS State OK \nCurrent active flags:$vFlagsStr"
    exit $codeOK
fi
exit $codeUNKNOWN
