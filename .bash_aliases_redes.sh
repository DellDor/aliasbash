#!/bin/bash
#Alias relacionados a red, independientes de la distribución

pcg(){
for i in {1..1000}; do
echo $i
ping -c2 www.google.co.ve
sleep 20
done
}

alias dameip='curl -q icanhazip.com' #'wget -q icanhazip.com -O -'
alias descarga='wget -c -P~/Descargas/'

actualizahora(){
if ! `whereis ntpdate` > /dev/null 2>&1; then
it ntpdate
fi
sudo bash -c "ntpdate -uv south-america.pool.ntp.org && hwclock -w" 
}
