#!/bin/bash
alias gdactivadir='gddirectoriobin=$HOME/Descargas/gdrive-linux-386'
gddirectoriobin="$HOME/Descargas/gdrive-linux-386"

gdsube(){
$gddirectoriobin upload -p "0Bzx6jwjHbTo1dFJfb0l3TXpPNXc" "$@"
}

gdbusca_nombre(){
gdactivadir
$gddirectoriobin list --query "name contains '$@'" #-m 15
}

gddescarga(){
gdactivadir
$gddirectoriobin download $@
}

gdexportaodt(){
gdactivadir
$gddirectoriobin export --mime application/vnd.oasis.opendocument.text $@
}

gdexportadocx(){
gdactivadir
$gddirectoriobin export --mime application/vnd.openxmlformats-officedocument.wordprocessingml.document $@
}

gdimporta(){
gdactivadir
$gddirectoriobin import -p "0Bzx6jwjHbTo1dFJfb0l3TXpPNXc" "$@"
}

gdimportaporextension(){
gdactivadir

for i in *.$1; do 
$gddirectoriobin import -p "0Bzx6jwjHbTo1dFJfb0l3TXpPNXc" "$i"
done
}

alias youtubedescarga='youtube-dl -f mp4 -t -c -R infinite --no-part --console-title'

youtubebusca(){
mkdir -p ~/Descargas/Videos
cd ~/Descargas/Videos
youtube-dl -F $1 |grep -v only
read -p "Señale un número para descargar: " n
youtube-dl -f $n -c $1 --no-part --console-title
}

reportesemanal(){
mkdir -p $HOME/Descargas/RepSem/
cd $HOME/Descargas/RepSem/
#youtube-dl -c -f 36 pmVT--Qp5iE
youtube-dl -c -f 36 https://www.youtube.com/user/BricenoSemanal #--playlist-start 4
}

