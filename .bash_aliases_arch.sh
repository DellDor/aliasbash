alias aliasedita='pluma ~/.bashrc'

######################
alias bkpaquetes='cp -vura /var/cache/pacman/pkg/*pkg* /run/media/dd/Archivos/Manjaro/paquetes'

######################
#Actualizar listado de repositorios con los más rápidos
actrepos() {
cantidad=5
wget http://git.manjaro.org/packages-sources/basis/blobs/raw/master/pacman-mirrorlist/mirrorlist -O /tmp/mirrorlist-git
cat /tmp/mirrorlist-git | grep \"Server\" | sed s'/# Server/Server/'g > /tmp/allservers
sudo cp -v /tmp/allservers /etc/pacman.d
sudo rankmirrors -n \$cantidad /etc/pacman.d/allservers | sudo tee /etc/pacman.d/mirrorlist2
sudo mv -v /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bk
sudo mv -v /etc/pacman.d/mirrorlist2 /etc/pacman.d/mirrorlist
}

#Descarga e instala paquetes
itd() {
sudo pacman -Sw --needed --noconfirm \$@
sudo pacman -S --needed \$@
}

instalaAUR() {
programa=\$1
mkdir -p /tmp/build/\$1
cd /tmp/build/\$1
wget -c http://aur.archlinux.org/packages/\$(echo \$1| head -c 2)/\$programa/PKGBUILD &&
wget -c http://aur.archlinux.org/packages/\$(echo \$1| head -c 2)/\$programa/\$programa.tar.gz && tar xzvf \$programa.tar.gz && cd ./\$programa && makepkg -s && sudo pacman -U *pkg.tar* && sudo mkdir -p ~/paquetes\ AUR/ && sudo cp -vi \$programa-*pkg.tar.xz ~/paquetes\ AUR/
}

######################Ayudas
ayuda() {
echo \"itd: alias que descarga e instala paquetes
sudo pacman -Sy: Actualiza listado de repositorios
sudo pacman -Suw --needed --noconfirm: descarga paquetes para actualizar 
sudo pacman -Su --needed: actualiza todos los paquetes
w: solo descarga lo requerido
--asdeps: instalar como dependecia
sudo pacman -S --needed PAQUETE: instala o actualiza un que no esté así en el sistema
sudo pacman -Ss palabras: busca información sobre palabras. También yaourt -Ss
yaourt COSA: busca información sobre COSA en todos los repos, hasta AUR\"
}
