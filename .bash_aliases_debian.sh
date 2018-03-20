#Aquí lo exclusivo a Debian y sus derivados: Mint, Ubuntu,etc
#Se debe privilegiar el uso de aptitude y apt-get en segunda instancia, para evitar conflictos en distribuciones rolling o semirroling
#Tratar de no usar apt porque dizque cambia mucho, segun su propia ayuda
#Se wctiva completación de aptitude:
complete -F _aptitude $default install purge show search

alias cdpkg='cd /var/cache/apt/archives'
alias a1='aptitude'
alias a2='sudo aptitude'
alias a3='sudo aptitude install --visual-preview --schedule-only dpkg:' #abre sin cambios marcados.
alias actsafe='sudo aptitude safe-upgrade --visual-preview' #Actualiza desactivando posibles eliminaciòn por dependencias.

act0(){
echo "Actualiza listado de paquetería, copiando los ya descargados"
#sudo cp -vua /var/lib/apt/lists/ /var/lib/apt/lists/partial/
sudo mkdir -p /var/tmp/listados_apt
sudo rsync -vmt /var/lib/apt/lists/* /var/tmp/listados_apt --exclude 'lock'
sudo rsync -vmt /var/tmp/listados_apt/* /var/lib/apt/lists/partial

sudo apt-get update -o Acquire::Pdiff=true -o Acquire::Check-Valid-Until=false

sudo rsync -vmt /var/lib/apt/lists/* /var/tmp/listados_apt --exclude 'lock'
}


act0s(){
echo "Actualiza listado de paquetería sin diferenciales"
sudo apt-get update -o Acquire::Pdiff=false -o Acquire::Check-Valid-Until=false
}

act1() {
echo "Solo descarga paquetes a actualizar"
sudo sh -c "aptitude -d safe-upgrade; apt-get -d dist-upgrade"
}

act2() {
echo "Actualiza todos los paquetes"
sudo sh -c "aptitude --visual-preview safe-upgrade; aptitude --visual-preview full-upgrade; apt-get upgrade"
}

marca_dependientes(){
sudo aptitude markauto $(aptitude search '?installed ?not(?automatic) ?or(?reverse-recommends(?installed),?reverse-Depends(?installed))' -F %p)
}

actmaquina(){
read -p "Actualiza los paquetes señalados en los archivos en /etc/aptitude-robot/pkglists/. Pulsa Enter para continuar" a
for i in $(ls -I "*.*" /etc/aptitude-robot/pkglist.d/); do
echo "Analizando $i

Continuamos"
#grep -v ^# /etc/aptitude-robot/pkglist.d/$i|awk '{print $2$1}'|xargs apt-get install -y --no-remove -y --allow-unauthenticated
grep -v ^# /etc/aptitude-robot/pkglist.d/$i|awk '{print $2$1}'|xargs -l1 sudo aptitude install -y -o APT:Get:Remove=No
#-o Acquire::AllowInsecureRepositories=yes
done
}

actimportantes(){
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

actuno_por_unoportamagno(){
xr4i25feb(){ for i in `aptitude search '~U' -F %p|xargs apt-cache --no-all-versions show | awk '$1 == "Package:" { p = $2 }; $1 == "Size:"    { printf("%d %s\n", $2, p) }'|sort -n|cut -d' ' -f2`; do 
#until ping -nq -c5 https://prenotaonline.esteri.it; do echo "Esperando internet..."; done
needrestart -b
echo "Se va a actualizar ${i}. Esperando 3 segundos para continuar"
sleep 3
apt-get install --no-remove --assume-no --allow-unauthenticated ${i}; done
#~ needrestart -ri
}
export -f xr4i25feb
sudo needrestart -b
su -c xr4i25feb
sudo needrestart -ri
}

#it(){
#Solo aptitude permite untrusted con opción directa
#echo "A instalar $@"
#sudo aptitude install --allow-untrusted -dy "$@"
#sudo apt-get install "$@"
#}

itd(){
echo "Descarga con wget paquete $@ con sus respectivas dependencias faltantes"
apt-get -y --print-uris --no-install-recommends install "$@" | egrep -o -e "(ht|f)tp://[^\']+" | xargs -l1 sudo wget -c -P/var/cache/apt/archives
}

itda(){
echo "Descarga con aria2c paquete $@ con sus respectivas dependencias faltantes"
apt-get -y --print-uris --no-install-recommends install "$@" | egrep -o -e "(ht|f)tp://[^\']+" | xargs -l1 sudo aria2c -c -s3 -x3 -d /var/cache/apt/archives
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

alias liberaapt='sudo rm -v /var/{lib/dpkg/lock,cache/apt/archives/lock,lock/aptitude}' #/var/lib/apt/lists/*'

alias reconfigurar_todo='sudo dpkg --configure -a'
#alias bo='sudo aptitude remove --purge --visual-preview'

#indica paquete que provee archivo
alias paquete_duegno='dpkg -S'

paquetes_huerfanos(){
echo "Crea listado de paquetes huérfanos"
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
curl http--remove-control-file[=true://localhost:3142/acng-report.html?doImport=Start+Import
sudo aptitude autoclean
sudo fdupes -nf -R /var/cache/apt{-cacher-ng,-cacher-ng/_import,}/ |grep .deb$|xargs sudo rm -v
curl "http://localhost:3142/acng-report.html?abortOnErrors=aOe&byPath=bP&byChecksum=bS&truncNow=tN&incomAsDamaged=iad&purgeNow=pN&doExpire=Start+Scan+and%2For+Expiration&calcSize=cs&asNeeded=an#bottom"
curl http://localhost:3142/acng-report.html?justRemoveDamaged=Delete+damaged
curl http://localhost:3142/acng-report.html?justRemove=Delete+unreferenced
sudo find /var/cache/apt-cacher-ng/ -not -path "*_import/*" -empty -exec rm -vr {} \;
}

limpia_apt_cachervisual(){
#Limpiar repo local con lo ya presente en apt-cacher-ng. Versión con gui en Firefox con imacros
sudo fslint-gui /var/cache/{apt,apt-cacher-ng}
sudo cp -vua /var/cache/apt/archives/*.deb /var/cache/apt-cacher-ng/_import
#Puede ser x-www-browser o gnome-browser o netsurf
cat > $HOME/iMacros/Macros/LimpiaApt.iim << FDA
SET !ERRORIGNORE YES
'TAB OPEN NEW
'TAB T=2
URL GOTO=http://localhost:3142/acng-report.html?doImport=Start+Import
WAIT SECONDS=3
URL GOTO=http://localhost:3142/acng-report.html?abortOnErrors=aOe&byPath=bP&byChecksum=bS&truncNow=tN&incomAsDamaged=iad&purgeNow=pN&doExpire=Start+Scan+and%2For+Expiration&calcSize=cs&asNeeded=an#bottom
SET !TIMEOUT_STEP 2
TAG POS=1 TYPE=BUTTON FORM=ID:mainForm ATTR=TXT:Check<SP>all
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ID:mainForm ATTR=NAME:doDelete
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ACTION:#top ATTR=NAME:doDeleteYes
WAIT SECONDS=3
URL GOTO=http://localhost:3142/acng-report.html?justRemoveDamaged=Delete+damaged
WAIT SECONDS=3
URL GOTO=http://localhost:3142/acng-report.html?justRemove=Delete+unreferenced
FDA

firefox imacros://run/?m=LimpiaApt.iim
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

apr(){
#Lo siguiente marca para dejar como está todo lo que se vaya a actualizar a versión inestable con aptitude-robot
temporal=$(mktemp)
for i in $(aptitude search ~U -F %p"$"%V| grep -e +b -e beta -e ~rc -e ~pre -e ~alpha|cut -d"$" -f1); do
echo "= $i" | tee -a $temporal
done
sudo cp -v $temporal /etc/aptitude-robot/pkglist.d/zzz_betas_automatico

#Continúa con la pregunta sobre si instalar/actualizar
until ping -nq -c5 8.8.8.8; do echo "Esperando internet..."; done
sudo aptitude-robot
}

alias apr-listas='sudo geany /etc/aptitude-robot/pkglist.d/*'

apr-local(){
sudo geany /etc/aptitude-robot/pkglist.d/99_esta_maquina 
}

aprselecciona(){
#Permite activar o desactivar archivos de apr
salida=""
cd /etc/aptitude-robot/pkglist.d/
listado=$(ls -I "*.*"|grep -v zzz)
listado="$listado $(ls *.inactivo)"

activos=$(ls -I "*.*"|grep -v zzz)
k=0
for i in $(echo $activos); do
archivos[$k]=$i
let k=k+1
salida="$salida --field=$i:CHK TRUE"
done

inactivos=$(ls *.inactivo)
for i in $(echo $inactivos); do
archivos[$k]=$i
let k=k+1
salida="$salida --field=$i:CHK FALSE"
done

resultado=$(yad --center --form --columns=3 $salida)
k=0
for i in $(echo $resultado| tr '|' '\n'); do
booleano[k]=$i
let k=k+1
done

let k=k-1

for ((i=0;i<=k;i++)); do
elfile=$(echo ${archivos[$i]}| awk -F '.inactivo' '{ print $1}')
if [ ${booleano[${i}]} = "TRUE" ]; then
sudo mv ${archivos[$i]} ${elfile}
else
sudo mv ${archivos[$i]} "${elfile}.inactivo"
fi
done
}

buscapaquete(){
apt-cache search "$@"
}
