#!/bin/bash

COLOR_RESET="\033[0m"
COLOR_RED="\033[1;1;31m"
COLOR_GREEN="\033[1;1;32m"
COLOR_YELLOW="\033[1;1;33m"
COLOR_BLUE="\033[1;1;34m"
COLOR_PINK="\033[1;1;35m"
COLOR_WHITE="\033[1;1;37m"

format_msg_maxline=1
format_msg_maxpos=0

function \
push_format_MSG() {
   local pos parm_name parm_value j
   local max_line=${format_msg_maxline} offset=0
   while [ "$1" ]
   do
      parm_name="${1%%=*}"
      parm_value="${1#*=}"
      for ((j=1; j<=format_msg_maxpos; j++))
      do
         if [ "${FORMAT_MSG[${j}]}" == "${parm_name}" ]
         then
            FORMAT_MSG[$((100*max_line+j))]="${parm_value}"
            break
         fi
      done
      if ((j>format_msg_maxpos))
      then
         FORMAT_MSG[$j]="${parm_name}"
         FORMAT_MSG_LEN[$j]="${#parm_name}"
         FORMAT_MSG[$((100*max_line+j))]="${parm_value}"
         format_msg_maxpos=$j
      fi
      if [ "${FORMAT_MSG[$((100*max_line+j))]:1:4}" = '033[' ]
      then
         offset=19
      else
         offset=0
      fi
      if ((((${#FORMAT_MSG[$((100*max_line+j))]}-offset))>$((${FORMAT_MSG_LEN[${j}]}+0))))
      then
         FORMAT_MSG_LEN[${j}]=$((${#FORMAT_MSG[$((100*max_line+j))]}-offset))
      fi
      shift
   done
   ((format_msg_maxline++))
}

function \
pull_format_MSG() {
   local slen offset=0
   for ((line=0; line<=$format_msg_maxline; line++))
   do
      slen=0
      for ((pos=1; pos<=$format_msg_maxpos; pos++))
      do
         if [ -z "${FORMAT_MSG[$((line*100+pos))]}" ]
         then
            FORMAT_MSG[$((line*100+pos))]=" "
         fi
         if [ "${FORMAT_MSG[$((line*100+pos))]:1:4}" = '033[' ]
         then
            msg_len=$((${#FORMAT_MSG[$((line*100+pos))]}-19))
         else
            msg_len=${#FORMAT_MSG[$((line*100+pos))]}
         fi
         printf "%$((slen+msg_len))b  " "${FORMAT_MSG[$((line*100+pos))]}"
         if [ "${FORMAT_MSG[$((line*100+pos+1))]:1:4}" = '033[' ]
         then
            offset=13
         fi
         slen=$((${FORMAT_MSG_LEN[$pos]}+offset-$msg_len))
         offset=0
      done
      echo
   done
format_msg_maxline=1
format_msg_maxpos=0
unset FORMAT_MSG FORMAT_MSG_LEN
}
