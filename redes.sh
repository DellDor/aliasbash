pcg(){
for i in {1..1000}; do
echo $i
ping -c2 www.google.co.ve
sleep 20
done
}

alias dameip='wget -q icanhazip.com -O -'
alias descarga='wget -c -P~/Descargas/'

actualizahora(){
sudo bash -c "ntpdate -uv south-america.pool.ntp.org && hwclock -w" 
}

alias youtube-dl='youtube-dl -c --no-part'
