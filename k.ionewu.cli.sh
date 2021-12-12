#!/bin/sh
. /usr/share/libubox/jshn.sh

NETLISTDFT="pppoe-vwan1 pppoe-vwan2 pppoe-vwan3 macvlan1 macvlan2 macvlan3 eth0 eth1 eth2 eth3 eth4 eth5"
IPV4URL="114.114.114.114"

UUID="$1"
OPENID="$2"
NETMAC=""

if [ -z "$UUID" ]; then
	echo no uid
	exit 1
fi
if [ -z "$OPENID" ]; then
	echo no openid
	exit 1
fi
GETOPKG=`opkg list | grep jshn`
if [ -z "$GETOPKG" ]; then
	echo pls install jshn
	exit 1
fi
GETCURL=`which curl`
if [ -z "$GETCURL" ]; then
	echo pls install curl
	exit 1
fi
unset GETOPKG
unset GETCURL

echo set uid $UUID 
echo set openid $OPENID

cd /tmp
mkdir dapengjiasu
cd dapengjiasu

CURLRE=""
SETNET=""
do_curl(){
	if [ -f "re.json" ]; then
		rm re.json
	fi
	curl -s $SETNET -H "Content-Type: application/json; charset=utf-8" \
		-d @post.json "$1" -o re.json
}

chk_re(){
	local GET=`cat re.json | grep ok`
	if [ -z "$GET" ]; then
		echo get error
		echo post
		cat post.json
		echo ret
		cat re.json
		exit 1
	fi
}

URL1="https://tan.ionewu.com/api/kuandai/log/user"
URL2="https://kdts.ionewu.com/c/query"
URL3="https://c.ionewu.com/wcjs/lan/find"
URL4="https://kdts.ionewu.com/c/status"
URL5="https://kdts.ionewu.com/c/open"

chknet(){
	NETLIST=`ifconfig | grep mtu | grep flag | awk -F':\ flag' '{print $1}'`
	IFACE=`ip -4 addr | awk '{if ($1 ~ /inet/ && $NF ~ /^[ve]/) {a=$NF}} END{print a}'`
	if [ -z "${NETLIST}" ]; then
		NETLIST="$NETLISTDFT"
	fi

	for netdev in ${NETLIST}
	do
		NETSTAT=`ifconfig $netdev`
		if [ ! -z "$NETSTAT" ]; then
			echo "find $netdev"
			NETSTAT=`ifconfig $netdev | grep inet | grep 127.0.0`
			if [ -z "$NETSTAT" ]; then
				PINGDAT=`ping -c 2 -I $netdev $IPV4URL | grep ttl`
				if [ "$netdev" = "$IFACE" ]; then
					NETMAC=$netdev
				fi
				if [ ! -z "$PINGDAT" ]; then
					NETMAC=$netdev
					break
				fi
			fi
		fi
	done
	echo "find netdev $NETMAC"
	if [ ! -z "$NETMAC" ]; then
		SETNET=" --interface $NETMAC"
	fi
}

chknet
echo $NETMAC

curl $SETNET "https://c.ionewu.com/user/devs?uid=${UUID}&openid=${OPENID}"

#1
json_init
json_add_string "uid" "$UUID"
json_add_string "openid" "$OPENID"
json_add_string "pid" ""
json_add_string "appid" ""
json_add_string "chanid" ""
json_add_string "refuid" ""
json_add_string "type" "open"
json_add_string "msg" "http://k.ionewu.com/web/app/"

json_dump > post.json
sed -i "s_\\\/_\/_g" post.json
#cat post.json

do_curl $URL1
chk_re
echo -n 1:
#cat re.json
mv re.json re1.json

do_curl $URL1
chk_re
echo -n 1: 
#cat re.json
mv re.json re1_1.json

#2
json_init
json_add_string "uid" "$UUID"                         
json_add_string "openid" "$OPENID"
json_add_int "type" 2

json_dump > post.json

do_curl $URL2
chk_re
echo -n 2: 
#cat re.json
mv re.json re2.json

#3

json_init                                                                           
json_add_string "uid" "$UUID"                               
json_add_string "openid" "$OPENID"      
json_dump > post.json
do_curl $URL3
echo -n 3: 
#cat re.json
mv re.json re3.json

#4
json_init                                                                                                                                    
json_add_string "uid" "$UUID"                                                                                                               
json_add_string "openid" "$OPENID"                                                                                      
json_add_int "type" 2                                                                                                                        

json_dump > post.json                                                                                                                        

do_curl $URL4
chk_re
echo -n 4: 
#cat re.json
mv re.json re4.json

#5
json_init
json_init(){
	echo -n call
}
json_add_string "uid" "$UUID"                                                                                                               
json_add_string "openid" "$OPENID"                                                                                      
json_add_string "pid" ""                                                                                                                     
json_add_string "appid" ""                                                                                                                   
json_add_string "chanid" ""                                                                                                                  
json_add_string "refuid" ""                                                                                                                  
json_add_string "type" "status_down"
GETRE=`cat re4.json`
json_add_string "msg" "${GETRE}"
#eval "`jshn -R re4.json`"
#json_select ..
json_dump > post.json
unset json_init
#cat post.json

do_curl $URL1
chk_re
echo -n 5: 
#cat re.json
mv re.json re5.json

#6
json_add_string "type" "check_down_success"
json_dump > post.json
do_curl $URL1
chk_re
echo -n 6: 
#cat re.json
mv re.json re6.json

#7
json_init 
json_add_string "uid" "$UUID"                                       
json_add_string "openid" "$OPENID"
json_add_string "pid" ""
json_add_int "type" 2
json_dump > post.json       
do_curl $URL2                                                
chk_re
echo -n 7: 
#cat re.json
mv re.json re7.json

#8
json_init                                                                           
json_init(){
	echo -n call
}                             
json_add_string "uid" "$UUID"                                       
json_add_string "openid" "$OPENID"
json_add_string "pid" ""      
json_add_string "appid" ""                             
json_add_string "chanid" ""
json_add_string "refuid" ""  
json_add_string "type" "check_down"                
GETRE=`cat re7.json`       
json_add_string "msg" "${GETRE}"    
json_dump > post.json         
unset json_init                                        
#cat post.json                                          

do_curl $URL1
chk_re
echo -n 8: 
#cat re.json
mv re.json re8.json

#9
json_add_string "type" "check_down_success"
json_dump > post.json                                  
do_curl $URL1                                          
chk_re
echo -n 9: 
#cat re.json
mv re.json re9.json

#10
json_init
json_add_string "uid" "$UUID"                                       
json_add_string "openid" "$OPENID"
json_add_int "type" 2
json_add_string "addr" ""
json_add_string "pid" ""
json_dump > post.json                                        
do_curl $URL5
chk_re
echo -n 10: 
#cat re.json
mv re.json re10.json

#11
json_init                                                                                                                                    
json_init(){                                                                                                                                 
	echo -n call                                                                                                                            
}                                                                                                                                            
json_add_string "uid" "$UUID"                                       
json_add_string "openid" "$OPENID"
json_add_string "pid" ""                                                                                                                     
json_add_string "appid" ""                                                                                                                   
json_add_string "chanid" ""                                                                                                                  
json_add_string "refuid" ""                                                                                                                  
json_add_string "type" "open_down"
GETRE=`cat re10.json`
json_add_string "msg" "${GETRE}"                                                                                                             
json_dump > post.json                                                                                                                        
unset json_init                                                                                                                              
#cat post.json                                                                                                                                

do_curl $URL1
chk_re
echo -n 11: 
#cat re.json
mv re.json re11.json
echo done

cd ..
rm -r dapengjiasu

exit 0

