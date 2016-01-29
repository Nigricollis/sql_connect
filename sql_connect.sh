#!/bin/bash
source ~/.bash_profile

#Created by tang 2016/1/26

#connectstring=sys/oracle as sydba
username=''
passwd=''
#sql_string=''
filename=''
#outfilename=''

ReturnValue_TF=0

usage()
{
        echo
        echo "Usage: sql_connect.sh [-v] [-n] [-h] [-u]! [-p]! [-f]!"
        echo "-v - Return with a value.(You can set your format in the file you appointed"
        echo "-n - Nothing return.(default) But you can spool something in your file that you appointed"
        echo "-h - This help text."
        echo "-u - Username.(Must)"
        echo "-p - Password.(Must)"
        #echo "-s - With the sql_string you want to execute.(Must)"
        echo "-f - Execute the sql in the file u appoint(Must)"
        #echo "-of - Spool the result in this file"
        echo
}

parse_options()
{
        set -- "$@"
        local ARGN=$#
        while [ "$ARGN" -ne 0 ]
        do
                case $1 in
                        -h) usage
                        exit 0
                ;;
                -v) ReturnVaule_TF=1
                ;;
                -n) ReturnValue_TF=0
                ;;
                -u) username=$2
                        #echo $username
                        shift 1
                        ARGN=$((ARGN-1))
                        ;;
                -p) password=$2
                        #echo $password
                        shift 1
                        ARGN=$((ARGN-1))
                        ;;
                -f) filename=$2
                        shift 1
                        ARGN=$((ARGN-1))
                        ;;
                ?*) echo "ERROR: Unkwown option."
                        usage
                        exit 0
                ;;
                esac
                shift 1
                ARGN=$((ARGN-1))
        done
}

return_Value(){
sqlplus -S $username/$password <<EOF
spool temp.csv
@$filename
spool off
exit
EOF
cat temp.csv
rm -rf temp.csv
}

return_Nothing(){
sqlplus -S $username/$password @$filename <<EOF
--set heading off feedback off pagesize 0 verify off echo off
EOF
}

if ([ "$0" = "$BASH_SOURCE" ] || ! [ -n "$BASH_SOURCE" ]);
then
        parse_options "$@"
        if [[ $filename = "" ]||[[ $username = "" ]]||[[ $password = "" ]];then
                usage
                exit 0
        fi
        if [ ! -f $filename ];then
                echo "$filename does not exist"
                exit 0
        fi
        if [ ! -z $ReturnValue_TF ];then
                return_Nothing
        else
                return_Value
        fi
fi
