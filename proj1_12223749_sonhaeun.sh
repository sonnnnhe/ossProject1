#!/bin/bash
echo "--------------------------"
echo "UserName: sonhaeun" 
echo "Student Number: 12223749"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

stop="N"
until [ $stop = "Y" ]
do
	clear
	read -p "Enter your choice [ 1-9 ] " choice
	printf "\n"
	case $choice in
	1)
		read -p "Please enter the 'movie id' (1~1682):" row
		printf "\n"
		cat u.item | awk -v row="$row" 'NR == row {print}'
		;;
	2)
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n):" answer
		printf "\n"
		if [ "$answer" == "y" ]
		then
			cat u.item | awk -F\| '$7~"1" {print $1, $2; count++} count == 10 {exit}'
		fi
		;;
	3)
		read -p "Please enter the 'movie id' (1~1682):" mi
		printf "\naverage rating of $mi: "
		cat u.data | awk -v mi="$mi" '$2 == mi {sum += $3; count++} END {printf "%.5f", sum/count}'
		;;
	4)
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" answer
		printf "\n"
		if [ "$answer" == "y" ]
		then
			cat u.item | sed 's/http.*)//g' | sed -n '1,10p'
		fi
		;;
	5)
		read -p "Do you want to get the data about users from 'u.user'?(y/n):" answer
		printf "\n"
		if [ "$answer" == "y" ]
		then
			for var in $(seq 1 10)
			do
				printf "user "
				cat u.user | sed 's/|.*//' | sed -n "${var}p" | tr '\n' ' '
				printf "is "
				cat u.user | sed 's/^[^|]*|\([^|]*\).*/\1/' | sed -n "${var}p" | tr '\n' ' '
				printf "years old "
				cat u.user | awk -v var="$var" -F\| 'NR == var && $3 == "M" {printf "male "}'
				cat u.user | awk -v var="$var" -F\| 'NR == var && $3 == "F" {printf "female "}'
				cat u.user | sed 's/^[^|]*|[^|]*|[^|]*|\([^|]*\).*/\1/' | sed -n "${var}p"
			done
		fi
		;;
	6)
		read -p "Do you want to get the data about users from 'u.user'?(y/n):" answer
		printf "\n"
		if [ "$answer" == "y" ]
		then
			for var in $(seq 1673 1682)
			do
				cat u.item | sed -e 's/\([0-9]\{2\}\)-\([A-Za-z]\{3\}\)-\([0-9]\{4\}\)/\3\2\1/g' -e 's/Jan/01/' -e 's/Oct/10/' -e 's/Sep/09/' -e 's/Feb/02/' -e 's/Mar/03/' | sed -n "${var}p"
			done
		fi
		;;
	7)
		read -p "Please enter the 'user id' (1~943):" ui
		cat u.data | awk -v ui="$ui" '$1 == ui {print $2}' | sort -n | tr '\n' '|' | sed 's/|$//'
		printf "\n\n"

		mi_array=($(cat u.data | awk -v ui="$ui" '$1 == ui {print $2}' | sort -n | head -10))
		for mi in "${mi_array[@]}"
		do
			cat u.item | sed 's/^\([^|]*|[^|]*\).*$/\1/' | sed -n "${mi}p"
		done
		;;
	8)
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" answer
		printf "\n"
		if [ "$answer" == "y" ]
		then
			ui=$(cat u.user | awk -F\| '$2 >= 20 && $2 <= 29 && $4 == "programmer" {print $1}')
			for ui_element in $ui
			do
				cat u.data | awk -v user="$ui_element" -F"\t" '$1 == user {print $2, $3}'
			done | awk '{sum[$1]+=$2; count[$1]++} END {for (i in sum) {printf "%s %.6g\n", i, sum[i]/count[i]}}' | sort -n
		fi
		;;
	9)
		echo "Bye!"
		stop="Y"
		;;
	esac
done
