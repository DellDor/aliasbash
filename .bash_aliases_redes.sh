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

actualizahora(){
if ! `whereis ntpdate` > /dev/null 2>&1; then
it ntpdate
fi
sudo bash -c "ntpdate -uv south-america.pool.ntp.org && hwclock -w" 
}

alias descarga='wget -c -P~/Descargas/'

descargaria(){
echo "Descarga $@ con aria2c"
aria2c -c -s3 -x3 -d $HOME/Descargas $@
}

alias redreinicia='if [[ $(ps -fe|grep nm-applet|grep -v grep)"x" = "x" ]]; then nm-applet & fi;sudo service NetworkManager stop;echo "Esperando 3 segundos"; sleep 3; sudo service NetworkManager start'

hayinternet(){
#Verifica si hay internet y muestra el estado
for i in {1..1000}; do
echo $i
until ping -nq -c3 8.8.8.8; do notify-send "<b>NO</b> hay internet"
done
#yad --center --window-icon="gtk-execute" --information --no-buttons --on-top --sticky --text "Hay internet" --timeout 2 --timeout-indicator=top 2>/dev/null
#notify-send "Hay internet"
sleep 1m
done
}

esperainternet(){
#Útil para ejecutar comandos cuando llegue haya conexión a internet
until ping -nq -c3 8.8.8.8; do echo "Sin internet aún..."
done
echo "Reanudada la conexión o cancelada la espera"
}
