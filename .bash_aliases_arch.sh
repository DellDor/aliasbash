

if [ -f /etc/bash_completion ]; then
	    . /etc/bash_completion
fi

xhost +local:root > /dev/null 2>&1

complete -cf sudo

shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dotglob
shopt -s expand_aliases
shopt -s extglob
shopt -s histappend
shopt -s hostcomplete
shopt -s nocaseglob

export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}
export HISTCONTROL=ignoreboth

alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ll='ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias la='ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias grep='grep --color=tty -d skip'
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano PKGBUILD'

# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# prompt
PS1='[\u@\h \W]\$ '
BROWSER=/usr/bin/xdg-open
###########fin .bashrc original Manjaro

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
