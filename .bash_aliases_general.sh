#Generales, que deben ser independientes de la distribución
#Todos los alias y funciones deben seguir principio KISS y hacer una sola cosa, pero hacerla bien, de forma que es preferible crear varios alias y que se llamen unos a otros en lugar de tener complejos

. /etc/bash_completion
#Activa autocompletar en sudo
complete -cf sudo
alias sudo='sudo '

tecladoesp(){
set LC_MESSAGES="es"
setxkbmap -layout es
}

tecladolatam(){
set LC_MESSAGES="es"
setxkbmap -layout latam
}

tecladoesp

# Errores y advertencias de GCC coloreadas
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

echo "==================
Arrancando .bashrc"

#De http://bashrcgenerator.com/ y https://www.kirsle.net/wizards/ps1.html; https://wiki.archlinux.org/index.php/Color_Bash_Prompt_%28Espa%C3%B1ol%29
export PS1="\[$(tput bold)\]\[$(tput setaf 2)\]\u\[$(tput setaf 1)\]@\[$(tput setaf 3)\]\h|\[$(tput setaf 6)\]\w|\[$(tput setaf 4)\]\\$ \[$(tput sgr0)\]"

alias abre='xdg-open'
alias suabre='sudo xdg-open'

alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ll='ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias la='ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias df='df -h' 

dir() {
#Si se añade R se convierte en recursivo 
ls --color=auto --format=vertical -lpa
echo "Total en este directorio" $(du -h -s `pwd`|awk '{print $1}') 
df -h -x tmpfs -x devpts -x usbfs -x devtmpfs
} 

aliasdescarga() {
fuente="https://raw.githubusercontent.com/DellDor/aliasbash/master"
if wget -N -P$HOME $fuente/.bash_aliases_general.sh; then
#if curl --fail -# $fuente/.bash_aliases_general.sh > $HOME/.bash_aliases_general.sh; then
echo "#!/bin/bash
. ~/.bash_aliases_general.sh
" > $HOME/.bash_aliases
chmod a+x $HOME/.bash_aliases_general.sh $HOME/.bash_aliases

for i in .bash_aliases_debian.sh .bash_aliases_redes.sh .bash_aliases_google; do
echo "Descargando $i"
#curl -# $fuente/$i > $HOME/$i
wget -N -P$HOME $fuente/$i
chmod a+x $HOME/$i
echo ". ~/$i" >> $HOME/.bash_aliases
done

echo "
if [ -f ~/.bash_aliases_local.sh ]; then
. ~/.bash_aliases_local.sh
fi" >> $HOME/.bash_aliases

#Detecta si se llama a bash_aliases desde .bashrc:
if ! grep -qe "~/.bash_aliases ]" ~/.bashrc; then
cat >> ~/.bashrc << EOD 
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi
EOD
fi
echo "Recuerda llamar a exec bash"
fi
}

aliasreinicia() {
echo "Ejecutando reinicio de bash"
exec bash
}

alias aliasedita='find $HOME -iname ".bash_aliases_*" -exec xdg-open {} \;; echo "Recuerda ejecutar exec bash"'

# exa - extractor de archivos
# uso: ex <file>
exa(){
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
     *)           echo "'$1' no puede ser extraido por ex()" ;;
   esac
 else
   echo "'$1' no es un archivo válido"
 fi
}

alias rm='rm -v'

#Enviar archivos a la papelera de reciclaje
alias borrar='gvfs-trash'

alias apagamonitor='xset dpms force off'

alias reinicia='systemctl reboot'
alias apaga='systemctl poweroff'
alias suspende='systemctl suspend'
alias cierrasesiongrafica='pkill -KILL -u $(whoami)'

temperatura() {
sudo sensors |grep °
sudo hddtemp /dev/sda
}

repite(){
#~ TODO: se pudiera identificar el primer parámetro, y si es numérico, repetir lo demás tantas veces indique eso
echo "Repite 100 veces el comando
$@"
	let "n=0"
	while [ "$n" -lt 100 ]
	do echo "$n *******"
`$@`
	  let "n+=1"
	  done
}

ayudaapaga(){
echo "
#~ Apagado programado por terminal
#~ halt, poweroff y shutdown
#~ sudo shutdown -h +5 #5 minutos
#~ sudo shutdown -h 22:30 # a las 22:30
#~ Para reiniciar el sistema tenemos dos: reboot y de nuevo shutdown,
#~ con todas las opciones mencionadas antes sólo que en lugar de usar
#~ el argumento -h (de halt), usaremos el -r (de reboot)
#~ sudo reboot
#~ sudo shutdown -r now
#~ sudo shutdown -r +5
#~ sudo shutdown -r 22:30  
#~ sudo shutdown -c #cancela la solicitud
"
}

#########Busca
alias busca='find "`pwd`" -iname "*$1*"'
alias buscacarpeta='find "`pwd`" -type d -iname "*$1*"' #Busca carpeta dentro de dónde se ejecute
alias buscarchivo='find "`pwd`" -type f -iname "*$1*"' #Busca archivo dentro de dónde se ejecute

alias buscamod30='find "`pwd`" -amin -30 -type f' #Busca archivos modificados en los últimos 30 minutos
alias buscacontenido='grep -lir'

#alias buscaqui='find "`pwd`" -iname'
alias buscavacios='find "`pwd`" -empty'

buscaaquisudo(){
echo "Busca con sudo todo lo que contenga \"$1\" en `pwd` y subcarpetas"
sudo find `pwd` -iname "*$1*"
}

buscaaqui(){
echo "Busca todo lo que contenga \"$1\" en `pwd` y subcarpetas"
direccion=${pwd}
find ${direccion} -iname "*${1}*" 2>/dev/null
echo "**************************
Esta búsqueda se hizo sin sudo"
}

borra_vacio() {
echo "Busca y pregunta para eliminar todos los directorios vacíos debajo del actual
find ./ -empty -exec rm -ri {} \;"
find ./ -empty -exec rm -vri {} \;
}

lightdm_actualiza() {
echo "Actualiza el archivo de configuración de lightdm para que entre automáticamente el usuario actual"
usuario=$(whoami)
export usuario

read -p "Pulsa Enter para añadir al usuario \" $usuario \" "

sudo sed -i "s/#autologin-user=/autologin-user=${usuario}/g" /etc/lightdm/lightdm.conf
sudo sed -i "s/#autologin-user-timeout=0/autologin-user-timeout=0/g" /etc/lightdm/lightdm.conf
}

#alias it='sudo pkcon install'
#alias itd_aqui='sudo pkcon download ./' 
#alias bo='sudo pkcon remove'
