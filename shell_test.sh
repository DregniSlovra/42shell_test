#!/bin/sh

echo -e "\n\e[0;32m\t\t---Testing script for 42sh---\e[0m\n"

prgm=$1
if [ -x $prgm ] && [ ! -d $prgm ]
then
    echo -e "Testing $prgm\e[0m\n"
else
    echo -e "Usage :\n\n\t./shell_test.sh [prgm to test]\n"
    echo -e "\tThe path isn't required"
    exit
fi

rm test/logs/*

fails=0
i=0
while read -r test
do
    i=$(($i+1))
    echo -en "\e[0;33m\tTest$i: \e[0m"
    echo -e $test | tcsh 2> test/temp2_tc 1> test/temp1_tc ; ret1=$?
    echo -e $test | ./$prgm 2> test/temp2_42 1> test/temp1_42 ; ret2=$?
    diff test/temp1_tc test/temp1_42 >> test/logs/test_${i}
    dif1=$?
    diff test/temp2_tc test/temp2_42 >> test/logs/test_${i}
    dif2=$?
    if [ $dif1 == 1 ] || [ $dif2 == 1 ] || [[ $ret1 != $ret2 ]]
    then
	touch test/logs/test_${i}
	echo -en "\e[0;31mFail \e[0m"
	echo "'$test'"
	if [[ $ret1 != $ret2 ]]
	then
	    echo -e "return are differents :\n${prgm} : $ret2\ntcsh : $ret1" >> test/logs/test_${i}
	fi
	echo -e "reported error : $i" >> test/logs/test_${i}
	fails=$(($fails+1))
    else
	echo -e "\e[0;32mok\e[0m"
    fi
done < test/tests

echo -e "\n\n\e[32m$(($i-$fails))\e[0m passed and \e[31m$fails\e[0m tests failed out of \e[33m$i\e[0m tests"

rm test/temp*
