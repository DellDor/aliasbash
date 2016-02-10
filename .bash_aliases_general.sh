#5 feb 2016
#Generales, que deben ser independientes de la distribución
#Todos los alias y funciones deben seguir principio KISS y hacer una sola cosa, pero hacerla bien, de forma que es preferible crear varios alias y que se llamen unos a otros en lugar de tener complejos

#Activa autocompletar en sudo
complete -cf sudo
set LC_MESSAGES="es"
setxkbmap -layout es

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

echo "==================
Arrancando .bashrc"

PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\]\[\e[1;37m\] '

alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ll='ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias la='ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias df='df -h' 


dir() { 
#Si se añade R se convierte en recursivo 
ls --color=auto --format=vertical -lpa|more 
echo "Total en este directorio" $(du -h -s `pwd`|awk '{print $1}') 
df -h -x tmpfs -x devpts -x usbfs 
} 
#########################

alias_descarga(){
fuente="https://raw.githubusercontent.com/DellDor/aliasbash/master"
#if wget -c -P$HOME $fuente/.bash_aliases_general.sh; then
if curl --fail -#O $fuente/.bash_aliases_general.sh; then
echo ".  ~/.bash_aliases_general.sh" > $HOME/.bash_aliases
chmod a+x $HOME/.bash_aliases_general.sh $HOME/.bash_aliases
{
for i in  .bash_aliases_debian.sh .bash_aliases_redes.sh; do
cd $HOME && { curl -#O $fuente/$i ; cd -; } 
chmod a+x $HOME/$i
echo ".  ~/$i" >> $HOME/.bash_aliases
done

#Detecta si se llama a bash_aliases desde .bashrc
if ! grep -qe "~/.bash_aliases ]" ~/.bashrc; then
echo "
if [ -e ~/.bash_aliases ]
then
exec ~/.bash_aliases
fi" >>  ~/.bashrc
fi
}
fi
exec bash
}

alias_reinicia(){
echo "Ejecutando reinicio de bash"
exec bash
}

alias aliasedita='ls $HOME/.bash_aliases*.sh| xargs -l1 xdg-open && aliasreinicia'

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
alias wget='wget -c'

alias apagamonitor='xset dpms force off'

alias reinicia='sudo reboot'
alias apaga='sudo poweroff'

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

ayudaapaga()
{
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

busca_aqui_sudo(){
echo "Busca con sudo todo lo que contenga \"$1\" en `pwd` y subcarpetas"
sudo find `pwd` -iname "*$1*"
}

busca_aqui(){
echo "Busca todo lo que contenga \"$1\" en `pwd` y subcarpetas"
direccion=${pwd}
find ${direccion} -iname "*${1}*" 2>/dev/null
echo "**************************
Esta búsqueda se hizo sin sudo"
}

borra_vacio() {
echo "Busca y pregunta para eliminar todos los directorios vacíos
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

############################
