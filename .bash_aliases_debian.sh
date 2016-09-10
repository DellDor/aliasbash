#jun 2016
#HACER: Pasar a _general todo lo que se pueda hacer directamente con pkcon (packagekit)
#Aquí lo exclusivo a Debian y sus derivados: Mint, Ubuntu,etc
#Se debe privilegiar el uso de apt-get y aptitude en segunda instancia, para evitar conflictos en distribuciones rolling o semirroling
#Tratar de no usar apt porque dizque cambia mucho, segun su propia ayuda
#MEJORA: Que se use pacapt desde 

complete -F _aptitude $default install purge show search

alias cdpkg='cd /var/cache/apt/archives'
alias a1='aptitude'
alias a2='sudo aptitude'

act0(){
echo "Actualiza listado de paquetería"
sudo apt-get update -o Acquire::Pdiff=true -o Acquire::Check-Valid-Until=false
}

act1() {
echo "Solo descarga paquetes a actualizar"
sudo sh -c "aptitude -d safe-upgrade; apt-get -d dist-upgrade"
}

act2() {
echo "Actualiza todos los paquetes"
sudo sh -c "aptitude --visual-preview safe-upgrade; aptitude --visual-preview full-upgrade; apt-get upgrade"
}

act_maquina(){
echo "Actualiza los paquetes señalados en ~.importantes_pkg"
if [ -f $HOME/.importantes_pkg ]; then
for i in $(cat $HOME/.importantes_pkg); do
sudo killall apt-get apt-mark
sudo apt-get install --no-remove -y --allow-unauthenticated $i
done
fi
}

act_importantes(){
echo "Actualiza paquetes de seguridad, importantes y requeridos" 
#sudo bash -c "grep -h '^deb.*security' /etc/apt/sources.list /etc/apt/sources.list.d/* >/tmp/borrame && aptitude safe-upgrade -o Dir::Etc::SourceList=/tmp/borrame -o Dir::Etc::sourceparts=/nonexistingdir &&
sudo bash -c "LANG=C apt-get dist-upgrade -s|grep Debian-Security| cut -d' ' -f2|sort|uniq|xargs apt-get install;
aptitude search '?or(~pstandard, ~pimportant, ~prequired, ~E) ~U' -F %p |xargs -l1 aptitude safe-upgrade -y"
}

alias act='read -p "Actualizar todo el sistema parte por parte. Pulsa Enter" a; act0; act_importantes; act1; act2'

act_axel() {
echo "Descarga con axel a /var/tmp/paquetes y al final mueve los descargados. Actualizar previamente la lista de repositorio"
mkdir -p  /var/tmp/paquetes
cd /var/tmp/paquetes
apt-get upgrade -y --print-uris | egrep -o -e "(ht|f)tp://[^\']+" |xargs -l1 sudo axel -an 3
sudo mv -vu /var/tmp/paquetes/*.deb /var/cache/apt/archives/
}

act_uno_por_uno_sin_conex(){
read -p "Si hay que instalar algo, no se ejecuta. No descarga nuevos paquetes. Enter empieza" a
sudo bash -c "aptitude search -F '%p' --disable-columns '~U'| grep -v -e ^lib[a-q] -e ^lib[s-z] -e ^libr[a-d] -e ^libr[f-z] -e ^libre[a-n] -e ^libre[p-z] -e ^wine -e python -e plasma -e ruby -e ^glib -e common -e data -e ^gir1. |xargs -l1 apt-get install --no-install-recommends --no-download"
#paplay /usr/share/sounds/KDE-Im-Nudge.ogg
}

actuno_por_uno(){
echo "################ #################### ########################
Actualiza uno por uno."
sudo bash -c 'for i in `aptitude search \'~U' -F %p|shuf`; do
if echo ${i}|grep -v -e ^lib[a-q] -e ^lib[s-z] -e ^wine -e python -e plasma -e ruby -e ^glib -e common -e data -e ^gir1. -e ^libr[a-d] -e ^libr[f-z] -e ^libre[a-n] -e ^libre[p-z] -e ^mono > /dev/null; then
echo "Analizando $i. Esperando 2 segundos para cancelar con seguridad.
"
sleep 2
echo "Seguimos"
cosa=$(ps -fe| grep -e apt-mark -e apt-get| grep -v grep)
if [[ $cosa > /dev/null ]]; then
killall apt-get apt-mark
fi
apt-get -d -y --no-remove install ${i}
apt-get install --no-remove -q=2 --allow-unauthenticated ${i} && apt-mark auto ${i}
fi
done
for i in `aptitude search \'~U' -F %p|shuf`; do
if echo ${i} > /dev/null; then
echo "Analizando $i. Esperando 2 segundos para cancelar con seguridad.
"
sleep 2
echo "Seguimos"
cosa=$(ps -fe| grep -e apt-mark -e apt-get| grep -v grep)
if [[ $cosa > /dev/null ]]; then
killall apt-get apt-mark
fi
apt-get -d -y --no-remove install ${i}
apt-get install --no-remove -q=2 --allow-unauthenticated ${i} && apt-mark auto ${i}
fi
done
'
aptitude
read -p "Enter para continuar con posibilidad de preguntar si borrar algún paquete" a
aptitude search -F '%p' --disable-columns '~U'|xargs -l1 sudo apt-get install --allow-unauthenticated
}

#it(){
#Solo aptitude permite untrusted con opción directa
#echo "A instalar $@"
#sudo aptitude install --allow-untrusted -dy "$@"
#sudo apt-get install "$@"
#}

itd(){
echo "Descarga paquete con sus respectivas dependencias faltantes"
apt-get -y --print-uris install "$1" | egrep -o -e "(ht|f)tp://[^\']+" | xargs -l1 sudo wget -c -P/var/cache/apt/archives
}

itdlis(){
echo "Muestra lista de direcciones de dónde descargar el paquete $1"
sudo apt-get install "$1" --print-uris -y| tr "'" "\n"|grep //
}

alias its='sudo aptitude install -R'
alias itp='sudo aptitude install'
alias itc='sudo aptitude install -r'
alias itv='sudo aptitude install --visual-preview'
alias bop='sudo aptitude remove'
alias itdp='sudo aptitude install -d'

alias libera_apt='sudo rm -v /var/{lib/dpkg/lock,cache/apt/archives/lock,lock/aptitude} /var/lib/apt/lists/*'

alias reconfigurar_todo='sudo dpkg --configure -a'
#alias bo='sudo aptitude remove --purge --visual-preview'

#idica paquete que provee archivo
alias paquete_duegno='dpkg -S'

paquetes_huerfanos() {
sudo deborphan -a |awk '{ print $2  }'|sort > /tmp/paquetes.txt; xdg-open /tmp/paquetes.txt
}

cp_paquete_a_cache(){
echo "Copia desde la carpeta pasada como parámetro a la cache local de paquetes"
find "$1" -iname "*.deb" -exec sudo cp -vu {} /var/cache/apt/archives/ \;
}

descargarepos_debian() {
#inicial="${PWD##}"
#cd /var/tmp
wget -N -P/var/tmp https://github.com/DellDor/InstaladoresDebian/raw/master/repositorios_debian.sh
chmod a+x /var/tmp/repositorios_debian.sh 
. /var/tmp/repositorios_debian.sh
#cd $inicial
}

reposexternosdes() {
find /etc/apt/sources.list.d/ -iname "*.list" -exec sudo sed -i 's/deb /#deb /g' {} \;
find /etc/apt/sources.list.d/ -iname "*.list" -exec sudo sed -i 's/##/#/g' {} \;
}

reposexternosact() {
find /etc/apt/sources.list.d/ -iname "*.list" -exec sudo sed -i 's/##/#/g' {} \;
find /etc/apt/sources.list.d/ -iname "*.list" -exec sudo sed -i 's/#deb /deb /g' {} \;
}

agrega_clave(){
echo -e "Procesando clave: $1"
gpg --keyserver subkeys.pgp.net --recv $1 | gpg --keyserver  keyserver.ubuntu.com --recv $1 && gpg --export --armor $1 && sudo apt-key add -
}

limpia_apt_cacher() {
#Limpiar repo local con lo ya presente en apt-cacher-ng. Si no está instalado, da error y continúa.
sudo fdupes -nf -R /var/cache/apt{-cacher-ng,-cacher-ng/_import,}/ |grep .deb$|xargs sudo rm -v
sudo cp -vua /var/cache/apt/archives/*.deb /var/cache/apt-cacher-ng/_import
curl http://localhost:3142/acng-report.html?doImport=Start+Import
sudo aptitude autoclean
sudo fdupes -nf -R /var/cache/apt{-cacher-ng,-cacher-ng/_import,}/ |grep .deb$|xargs sudo rm -v
curl "http://localhost:3142/acng-report.html?abortOnErrors=aOe&byPath=bP&byChecksum=bS&truncNow=tN&incomAsDamaged=iad&purgeNow=pN&doExpire=Start+Scan+and%2For+Expiration&calcSize=cs&asNeeded=an#bottom"
curl http://localhost:3142/acng-report.html?justRemoveDamaged=Delete+damaged
curl http://localhost:3142/acng-report.html?justRemove=Delete+unreferenced
}

limpia_apt_cachervisual(){
#Limpiar repo local con lo ya presente en apt-cacher-ng. Versión con gui
#HACER: Revisar si está instalado netsurf
#~sudo fslint-gui /var/cache/{apt,apt-cacher-ng}
sudo cp -vua /var/cache/apt/archives/*.deb /var/cache/apt-cacher-ng/_import
#Puede ser x-www-browser o gnome-browser
netsurf http://localhost:3142/acng-report.html?doImport=Start+Import
sudo aptitude autoclean
netsurf "http://localhost:3142/acng-report.html?abortOnErrors=aOe&byPath=bP&byChecksum=bS&truncNow=tN&incomAsDamaged=iad&purgeNow=pN&doExpire=Start+Scan+and%2For+Expiration&calcSize=cs&asNeeded=an#bottom"
netsurf http://localhost:3142/acng-report.html?justRemoveDamaged=Delete+damaged
netsurf http://localhost:3142/acng-report.html?justRemove=Delete+unreferenced
echo "Filtros usables:
  */archives*/
  */_import/*"
sudo fslint-gui /var/cache/{apt,apt-cacher-ng}
}


alias limpia_cache_apt='sudo aptitude autoclean'

limpia_liquorix(){
read -p "Ejecutar sólo luego de instalar liquorix y reiniciar el sistema, de manera que ese sea el kernel que corre. Enter para continuar" a
#Solo Liquorix
actual=$(dpkg --get-selections | grep -e linux-image -e linux-header|grep $(uname -r)| awk '{print $1}')
echo "El núcleo actual es: $actual"

#Otros
otros=$(dpkg --get-selections | grep -e linux-image -e linux-header|grep -v liquorix| awk '{print $1}')

if  [ "$otros" > /dev/null ]; then
echo "Otros núcleos instalados (no liquorix) $otros"
#Eliminamos todos los que no sean liquorix
sudo aptitude purge --visual-preview  $otros
#por si hay algún mensaje de error: sudo aptitude install --visual-preview  $otros
else
echo "No hay kernels no liquorix instalado"
fi

#Versiones viejas de Liquorix
echo "A continuación kernels liquorix antiguos"
sudo aptitude purge --visual-preview  $(dpkg --get-selections | grep -e linux-image -e linux-header|grep -v $(uname -r)|awk '{print $1}'|grep -ve linux-image-liquorix -ve linux-headers-liquorix)
#Si no se hizo automáticamente, actualizamos Burg o grub:
#sudo update-burg || sudo update-grub
}

acttodo(){
export -f act0 act_importantes actuno_por_uno
su -c 'act0; act_importantes; actuno_por_uno; aptitude --visual-preview safe-upgrade'
}

liberaespacio(){
#Pensado con internet, para recuperar cosas borradas y con bleachbit como centro.
#http://www.cyberciti.biz/faq/how-do-i-find-the-largest-filesdirectories-on-a-linuxunixbsd-filesystem/
seguir(){
df -h -x tmpfs -x devpts -x usbfs -x devtmpfs
read -p "

Enter para seguir borrando. Ctrl+C para parar" a
}
miracache(){
sudo find /var/cache/ -printf '%s %p\n'| sort -nr| head -n 10| xargs dirname|sort|uniq|grep -v "^.$"|sort|uniq|xargs -l1 sudo xdg-open
}
miracache
seguir
miracache
seguir
sudo rm -rv /var/cache/apt-cacher-ng/packages.linuxmint.com/pool/import/f/firefox/
sudo rm -rv /var/cache/apt-cacher-ng/sparkylinux.org/repo/pool/main/s/sparky/
seguir
#HACER: verificar instalación bleachbit
bleachbit
seguir
sudo bleachbit
seguir
#HACER: Verificasr si está instalado apt-cacher-ng
sudo cp -vua /var/cache/apt/archives/*.deb /var/cache/apt-cacher-ng/_import
sudo find /var/cache -empty -type d -exec rm -rv {} \; 
x-www-browser http://localhost:3142/acng-report.html?doImport=Start+Import
#HACER: verificar instalación fdupes
sudo fdupes -nf -R /var/cache/apt{-cacher-ng,-cacher-ng/_import,}/ |grep .deb$|xargs sudo rm -v
x-www-browser http://localhost:3142/acng-report.html?justRemoveDamaged=Delete+damaged
seguir
x-www-browser http://localhost:3142/acng-report.html?justRemove=Delete+unreferenced
sudo find /var/cache -empty -type d -exec rm -rv {} \; 
seguir
sudo aptitude clean
seguir
sudo rm -v /var/cache/apt-cacher-ng/_import/*.deb
seguir
sudo rm -rv /var/lib/apt/lists/*
seguir
rm -rv ~/.fgfs/TerraSync/*
seguir
sudo find /var/tmp -size +512k -exec rm {} \;
rm -i $(sudo find /var/tmp -type f -printf '%s %p\n'| sort -nr |cut -d" " -f2)
seguir
miracache
}
