#!/bin/bash
vars=$(<container.cfg)
set -- $vars
echo $1

#Need Kernel tunning
ulimit -n 600000
ulimit -u 600000
sysctl net.ipv6.conf.ens3.proxy_ndp=1
sysctl net.ipv6.conf.all.proxy_ndp=1
sysctl net.ipv6.conf.default.forwarding=1
sysctl net.ipv6.conf.all.forwarding=1
sysctl net.ipv6.ip_nonlocal_bind = 1
sysctl -p
#Generate ip.list

array=( 1 2 3 4 5 6 7 8 9 0 a b c d e f )
MAXCOUNT=`echo $1 |awk -F'=' '{print $2}'`
NETWORK=`echo $2 |awk -F'=' '{print $2}'`
EXTERNAL_IP=`echo $3 |awk -F'=' '{print $2}'`
FIRSTPORT=`echo $4 |awk -F'=' '{print $2}'`
USER=`echo $5 |awk -F'=' '{print $2}'`
PASSWORD=`echo $6 |awk -F'=' '{print $2}'`
count=1

rnd_ip_block ()
{
    a=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
    b=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
    c=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
    d=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
    echo $NETWORK:$a:$b:$c:$d
}

generate_ip ()
{
while [ "$count" -le $MAXCOUNT ]        # Generate 20 ($MAXCOUNT) random numbers.
do
        rnd_ip_block
        let "count += 1"                # Count +1.
        done
}

#Generate 3proxy.cfg
echo \
"daemon
maxconn 1
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
flush
auth strong
users $USER:CL:$PASSWORD
allow $USER" >3proxy.cfg

port=$FIRSTPORT
count=1
for i in $(generate_ip); do
    echo "proxy -6 -n -a -p$port -i$EXTERNAL_IP -e$i" >>3proxy.cfg
    ((port+=1))
    ((count+=1))
    if [ $count -eq 10001 ]; then
        exit
    fi
done

#Generate ndppd.conf
echo \
"route-ttl 30000
proxy ens3 {
   router no
   timeout 500   
   ttl 30000
   rule $NETWORK::/64 {
      static
   }
}">ndppd.conf

#Generate init.sh
echo \
"#!/bin/bash
/sbin/ip -6 addr add $NETWORK::2/64 dev ens3
/sbin/ip -6 route add default via $NETWORK::1
/sbin/ip -6 route add local $NETWORK::/64 dev lo
/root/3proxy/src/3proxy /root/3proxy/3proxy.cfg
/root/ndppd/ndppd -c /root/ndppd/ndppd.conf
exit 0" >init.sh
