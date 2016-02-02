#Todo lo exclusivo a Debian y sus derivados: Mint, Ubuntu,etc
#Se debe priviligear el uso de apt-get y aptitude en segunda instancia, para evitar conflictos en distribuciones rolling o semirroling
#Tratar de no usar apt porque dizque cambia mucho, segun su propia ayuda

alias cdpkg='cd /var/cache/apt/archives'
alias a1='aptitude'
alias a2='sudo aptitude'

act0() {
echo "Actualiza listado de paquetería"
sudo apt-get update -o Acquire::Pdiff=true -o Acquire::Check-Valid-Until=false
}

act1() {
echo "Solo descarga paquetes a actualizar"
sudo sh -c "aptitude -d safe-upgrade; apt-get -d dist-upgrade"
}

act2() {
echo "Buscar actualizar todos los paquetes"
sudo sh -c "aptitude --visual-preview safe-upgrade; aptitude --visual-preview full-upgrade; apt-get upgrade"
}

alias act='read -p "Actualizar todo el sistema parte por parte. Pulsa Enter" a; act0; act1; act2; act3'

actunoporunosinconex(){
read -p "Si hay que instalar algo, no se ejecuta. No descarga nuevos paquetes. Enter empieza" a
sudo bash -c "aptitude search -F '%p' --disable-columns '~U'| grep -v -e ^lib[a-q] -e ^lib[s-z] -e ^libr[a-d] -e ^libr[f-z] -e ^libre[a-n] -e ^libre[p-z] -e ^wine -e python -e plasma -e ruby -e ^glib -e common -e data -e ^gir1. |xargs -l1 apt-get install --no-install-recommends --no-download"
paplay /usr/share/sounds/KDE-Im-Nudge.ogg
}

actunoporuno(){
echo "Instala nuevos paquetes y busca descargar lo que falte. 

Previamente intenta con:
sudo aptitude safe-upgrade #--visual-preview


Empieza con los de Security. Sigue con importantes y básicos y continúa con los demás" 

sudo bash -c "grep -h '^deb.*security' /etc/apt/sources.list /etc/apt/sources.list.d/* >/tmp/borrame && aptitude safe-upgrade -o Dir::Etc::SourceList=/tmp/borrame -o Dir::Etc::sourceparts=/nonexistingdir && \
aptitude safe-upgrade $(aptitude search '?or(~pstandard, ~pimportant, ~prequired, ~E) ~U' -F %p) --visual-preview && \
apt-get upgrade -s |grep 'Inst '| cut -d' ' -f2| grep -v -e ^lib[a-q] -e ^lib[s-z] -e ^libr[a-d] -e ^libr[f-z] -e ^libre[a-n] -e ^libre[p-z] -e ^uno -e ^ure -e ^wine -e python -e plasma -e ruby -e ^glib -e common -e data -e ^gir1. -e python |xargs -l1 aptitude install --safe-resolver --allow-new-installs --allow-untrusted -y"
read -p "Enter para continuar con posibilidad de preguntar si borrar algún paquete" a
sudo bash -c "aptitude search -F '%p' --disable-columns '~U'| grep -v -e ^lib[a-q] -e ^lib[s-z] -e ^wine -e python -e plasma -e ruby -e ^glib -e common -e data -e ^gir1. -e ^libr[a-d] -e ^libr[f-z] -e ^libre[a-n] -e ^libre[p-z]|xargs -l1 apt-get install"
#paplay /usr/share/sounds/KDE-Im-Nudge.ogg
}
it(){
#Solo aptitude permite untrusted con opción directa
echo "A instalar $@"
sudo aptitude install --allow-untrusted -dy "$@"
sudo apt-get install "$@"
}

alias its='sudo aptitude install -R'
alias itc='sudo aptitude install -r'
alias itv='sudo aptitude install --visual-preview'

liberapt() {
sudo rm -v /var/lib/dpkg/lock /var/cache/apt/archives/lock /var/lock/aptitude
}

alias reconfigurartodo='sudo dpkg --configure -a'
alias bo='sudo aptitude remove --purge --visual-preview'

descargapaq() {
echo "Descarga paquete con sus respectivas dependencias faltantes"
sudo apt-get -y --print-uris install "$1" | egrep -o -e "(ht|f)tp://[^\']+" | xargs -l1 sudo wget -c -P/var/cache/apt/archives/partial
}

cppaqueteacache(){
echo "Copia desde la carpeta pasada como parámetro a la cache local de paquetes"
find "$1" -iname "*.deb" -exec sudo cp -vu {} /var/cache/apt/archives/ \;
}

agregaclave(){
echo -e "Procesando clave: $1"
gpg --keyserver subkeys.pgp.net --recv $1 | gpg --keyserver  keyserver.ubuntu.com --recv $1 && gpg --export --armor $1 && sudo apt-key add -
}
