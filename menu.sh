#!/bin/bash

function read_interfaces() {
  menu=($(cat /proc/net/dev | egrep ".*:" | cut -d: -f 1 | sed "s/ //g"))

  for i in ${!menu[@]}; do
    if [[ ${menu[i]} == "lo" ]]; then
      unset menu[i];
    fi
  done
}

draw_menu() {
    for i in "${menu[@]}"; do
        if [[ ${menu[$cur]} == $i ]]; then
          # tput setaf 2; echo " > $i"; tput sgr0
          tput setaf 2; echo -e "\e[0;30;42m$i\e[m"; tput sgr0
        else
            echo "$i";
        fi
    done
}

clear_menu()  {
    for i in "${menu[@]}"; do tput cuu1; done
    tput ed
}

function show_selection() {
  # Draw initial Menu
  draw_menu
  while read -sN1 key; do # 1 char (not delimiter), silent
      # Check for enter/space
      if [[ $key == " " || $key == "" ]]; then
        echo
        echo ${menu[$cur]}
        echo
        exit 0
      fi

      # catch multi-char special key sequences
      read -sN1 -t 0.0001 k1; read -sN1 -t 0.0001 k2; read -sN1 -t 0.0001 k3
      key+=${k1}${k2}${k3}
      echo "'$K1' '$K2' '$K3'" >> dump

      case "$key" in
          # cursor up, left: previous item
          i|j|$'\e[A'|$'\e0A'|$'\e[D'|$'\e0D') ((cur > 0)) && ((cur--));;
          # cursor down, right: next item
          k|l|$'\e[B'|$'\e0B'|$'\e[C'|$'\e0C') ((cur < ${#menu[@]}-1)) && ((cur++));;
          # home: first item
          $'\e[1~'|$'\e0H'|$'\e[H')  cur=0;;
          # end: last item
          $'\e[4~'|$'\e0F'|$'\e[F') ((cur=${menu[@]}-1));;
           # q, carriage return: quit
          q|''|$'\e')echo "Aborted." && exit;;

          $'\n') break;;
      esac
      # Redraw menu
      clear_menu
      draw_menu
  done
  selection="${menu[$cur]}";
}

unset menu
read_interfaces
show_selection
clear
