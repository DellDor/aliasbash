#Instaladores directos desde repositorios, servidores, etc.
#Algún día debería independizarse en una aplicación o hacer repositorios propio y subir lo publicado aquí. Puede ser base del guión e descarga y subida
#Se descargarán todos a /var/tmp/paquetes para que sea borrables, pero si se va la energía o conexión se pueda continuar luego

#PENDIENTES
#peazip

des_rambox(){
#Paquete Debian en releases de github 
#http://rambox.pro/#download https://github.com/saenzramiro/rambox/releases
directorio="https://github.com/saenzramiro/rambox/releases"
if [ $(uname -m) == 'i686' ]; then
plataforma="ia32"
else
plataforma="x64"
fi

mkdir -p /var/tmp/paquetes
wget -c -P /var/tmp/paquetes "https://github.com"$(curl -q -L -o - $directorio|grep $plataforma.deb|head -n 1|cut -d\" -f2)
sudo gdebi-gtk /var/tmp/Rambox*
}

des_telegram(){
#Descarga directo desde debian pool para descargar última versión y con aria2. Find con tiempo para gdebi
mkdir -p /var/tmp/paquetes
if [ $(uname -m) == 'i686' ]; then
plataforma="i386"
else
plataforma="amd64"
fi
directorio=http://httpredir.debian.org/debian/pool/main/libt/libtgvoip
aria2c -c -s3 -x3 -d /var/tmp/paquetes HOME/Descargas/Paquetes $directorio/$(curl -q -L -o - $directorio|grep $plataforma.deb|grep -v dev_| cut -d\" -f8)

directorio=http://httpredir.debian.org/debian/pool/main/t/telegram-desktop
aria2c -c -s3 -x3 -d /var/tmp/paquetes $directorio/$(url -q -L -o - $directorio|grep $plataforma.deb|grep -v dev_| cut -d\" -f8)
find /var/tmp/paquetes -iname "*.deb" -amin -30 -exec sudo gdebi-gtk {} \;
}
}

des_opera(){
mkdir -p ~/Descargas/Paquetes
version=$(curl -q -o - get.geo.opera.com/pub/opera/desktop/|grep href|tail -n1|cut -d\" -f2|cut -d/ -f1)
#Se separa versión porque se us dos veces en ls descarga
aria2c -c -s3 -x3 -d $HOME/Descargas/Paquetes http://get.geo.opera.com/pub/opera/desktop/${version}/linux/opera-stable_${version}_i386.deb
find $HOME/Descargas/Paquetes -iname "*.deb" -amin -5 -exec sudo gdebi-gtk {} \;
}
