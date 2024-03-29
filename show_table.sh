#!/usr/bin/bash

# $1 is the name of the database you are currently using
clear
echo
list_tables $1
echo
echo -e "${GREEN}Showing a table in $1 database${NC}"
echo
while [[ true ]];
do
 	echo -ne "${PROMPT}Enter The Name Of The Table : ${NC}"
	#back 
	if ! read table_name; then
		return
	fi

	#check for empty string
	if ! is_not_null $table_name; then
		echo 
		echo -e "${RED}Name Cannot Be Null!${NC}"
		continue
	fi

	#check for existing table name
	if ! find_table $1 $table_name; then
		echo 
		echo -e "${RED}Table Does not Exist!${NC}"
		continue
	fi

	break
done 
# printing the table columns from the metadata                                      # to print it $1 $2 At same Line 
awk -v var=$table_name 'BEGIN {FS=":"; print "\t\tTable Name: " var "\n"} {if(NR>1) printf $1"<"$2">\t\t"} END{printf "\n"}' "./Databases/$1/${table_name}_Meta"
# printing the table cells from the file itself
echo "--------------------------------------------------------------"   # to ignore (:) in all rows in table 
awk 'BEGIN{FS=":";OFS="\t | \t";ORS="\n";}{  $1=$1; print substr($0, 1, length($0)-1)}' "./Databases/$1/$table_name"
echo
echo
echo "press Enter to return!"
read
return

