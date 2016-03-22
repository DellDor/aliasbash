#feb 2016
#TODO: Hacer alias de paquetería agnóstica, usando pkcon (packagekit) con todo lo que se pueda hacer con él
#Aquí lo exclusivo a Debian y sus derivados: Mint, Ubuntu,etc
#Se debe priviligear el uso de apt-get y aptitude en segunda instancia, para evitar conflictos en distribuciones rolling o semirroling
#Tratar de no usar apt porque dizque cambia mucho, segun su propia ayuda

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
aptitude search '?or(~pstandard, ~pimportant, ~prequired, ~E) ~U' -F %p |xargs aptitude safe-upgrade -y"
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
sudo bash -c 'for i in `aptitude search \'~U' -F %p`; do
if echo ${i}|grep -v -e ^lib[a-q] -e ^lib[s-z] -e ^wine -e python -e plasma -e ruby -e ^glib -e common -e data -e ^gir1. -e ^libr[a-d] -e ^libr[f-z] -e ^libre[a-n] -e ^libre[p-z] -e ^mono > /dev/null; then
echo "Analizando $i"
killall apt-get apt-mark
apt-get install --no-remove -q=2 --allow-unauthenticated ${i} && apt-mark auto ${i}
fi
done'
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
alias itc='sudo aptitude install -r'
alias itv='sudo aptitude install --visual-preview'

alias libera_apt='sudo rm -v /var/{lib/dpkg/lock,cache/apt/archives/lock,lock/aptitude}'

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

descarga_repos_debian() {
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
