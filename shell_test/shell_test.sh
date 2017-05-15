#!/bin/sh

echo -e "\n\e[0;32m\t\t---Testing script for 42sh---\e[0m\n"

prgm=$1
if [ -x $prgm ] && [ ! -d $prgm ]
then
    echo -e "Testing $prgm\e[0m\n"
elif [ $1 ]
then
    if [ $1 == -r ]
    then
	echo -e "\e[31mDeleting all log files\e[0m"
	if [ "$(ls -A shell_test/test/logs)" ]
	then
	    rm shell_test/test/logs/*
	fi
	exit
    elif [ $1 == -h ]
    then
	cat shell_test/test/Usage
	exit
    fi
else
    echo -e "Usage :\n\n\t./shell_test.sh [prgm to test]\n"
    echo -e "\t./shell_test.sh [option]\n"
    echo -e "\n\t-r\tDelete all log files in shell_test/test/logs\n"
    exit
fi

if [ "$(ls -A shell_test/test/logs)" ]
then
    rm shell_test/test/logs/*
fi

fails=0
i=0
while read -r test
do
    i=$(($i+1))
    echo -en "\e[0;33m\tTest$i: \e[0m"
    echo -e $test | tcsh 2> shell_test/test/temp2_tc 1> shell_test/test/temp1_tc ; ret1=$?
    echo -e $test | ./$prgm 2> shell_test/test/temp2_42 1> shell_test/test/temp1_42 ; ret2=$?
    diff shell_test/test/temp1_tc shell_test/test/temp1_42 >> shell_test/test/logs/test_${i}
    dif1=$?
    diff shell_test/test/temp2_tc shell_test/test/temp2_42 >> shell_test/test/logs/test_${i}
    dif2=$?
    if [ $dif1 == 1 ] || [ $dif2 == 1 ] || [[ $ret1 != $ret2 ]]
    then
	touch shell_test/test/logs/test_${i}
	echo -en "\e[0;31mFail \e[0m"
	echo "'$test'"
	if [[ $ret1 != $ret2 ]]
	then
	    echo -e "return are differents :\n${prgm} : $ret2\ntcsh : $ret1" >> shell_test/test/logs/test_${i}
	fi
	echo -e "reported error : $i" >> shell_test/test/logs/test_${i}
	fails=$(($fails+1))
    else
	echo -e "\e[0;32mok\e[0m"
    fi
done < shell_test/test/tests

echo -e "\n\n\e[32m$(($i-$fails))\e[0m passed and \e[31m$fails\e[0m tests failed out of \e[33m$i\e[0m tests"

rm shell_test/test/temp*
