#!/usr/bin/bash

# $1 is the name of the database you are currently using
clear
echo
list_tables $1
echo
echo -e "${GREEN}Creating table in ${LBLUE}$1${GREEN} database${NC}"
echo
while [[ true ]]; do
	echo -ne "${PROMPT}Enter The Name Of The Table : ${NC}"
	#back 
	if ! read table_name; then
		return
	fi
	#disallowing special characters in  names --  \ must be handled
	if [[ $table_name == *['!'@#\$%^\&*()-+\.\/]* ]]; then
		echo 
		echo -e "${RED} ! @ # $ % ^ () + . -  are not allowed!${NC}"
		continue
	fi
	#check for empty string
	if ! is_not_null $table_name; then
		echo 
		echo -e "${RED}Name Cannot Be Null!${NC}"
		continue
	fi
	#rejecting spaces in table name
	if [[ "$table_name" = *" "* ]]; then
		echo 
		echo -e "${RED}Spaces Are Not Allowed!${NC}"
		continue
	fi
	#check for existing table name
	if  find_table $1 $table_name; then
		echo 
		echo -e "${RED}Table Does Exist!${NC}"
		continue
	fi
	break
done 
# cheek num_cols
while [[ true ]]; do
	echo -ne "${PROMPT}Enter Number Of Columns : ${NC}"
	if ! read num_of_cols; then
		return
	fi
	if ! is_not_null $table_name; then
		echo 
		echo -e "${RED}Number Cannot Be Null!${NC}"
		continue
	fi
	if [ "$num_of_cols" = 0 ]; then
		echo 
		echo -e "${RED}Number Cannot Be Zero!${NC}"
		continue
	fi
	if [[ "$num_of_cols" =~ ^[-][0-9]+$ ]]; then
		echo 
		echo -e "${RED}Number Cannot Be Negative!${NC}"
		continue
	fi
	if [[ "$num_of_cols" =~ ^[-+]?[0-9]+\.[0-9]*$ ]]; then
		echo 
		echo -e "${RED}Number Cannot Be Float!${NC}"
		continue
	fi
	reg='^[0-9]+$'
	if ! [[ "$num_of_cols" =~ $reg ]]; then
		echo 
		echo -e "${RED}Only Numbers Are Needed!${NC}"
		continue
	fi
	break
 done 

#two arrays for columns names and columns datatypes
cols_names=()
cols_datatypes=()
# cheek P.K
while [[ true ]]; do
	#take the primary key column name 
	echo -ne "${PROMPT}Please Enter Primary Key Column Name : ${NC}"
	#back
	if ! read pk_name; then
		return
	fi
	if [[ $pk_name == *['!'@#\$%^\&*()-+\.\/]* ]]; then
		echo 
		echo -e "${RED} ! @ # $ % ^ () + . -  are not allowed!${NC}"
		continue
	fi
	#checking for empty string
	if ! is_not_null $pk_name ; then
		echo
		echo -e "${RED}Name Cannot Be Null!${NC}"
		continue
	fi
	#rejecting spaces in column name
	if [[ "$pk_name" = *" "* ]]; then
		echo 
		echo -e "${RED}Spaces Are Not Allowed!${NC}"
		continue
	fi
	#rejecting colons in column name
	if [[ "$pk_name" = *:* ]]; then
		echo 
		echo -e "${RED}Colons Are Not Allowed!${NC}"
		continue
	fi
	break
done
# appending it the array   first element Primary Key Array(cols_names)
cols_names+=("$pk_name")
echo -e "${YELLOW}Datatypes  are strings <str>, alphanumeric <alnum>, and integers <int>"
echo -ne "${PROMPT}Enter The Primary Key datatype : ${NC}"
if ! read pk_type; then
	return
fi
#taking the datatype of the pk column
while [[ true ]]; do
	case $pk_type in
		str )
			break;;
		int )
			break;;
		alnum )
			break;;
		* )
			echo -ne "${RED}Please Enter A Supported Datatype : ${NC}"
			if ! read pk_type; then
				return
			fi;;
	esac
done
#appending to the array 
cols_datatypes+=("$pk_type")     # first element Type ofPrimary Key Array(cols_datatype)
for (( i = 1; i < $num_of_cols; i++ )); do
	echo
	while [[ true ]]; do
		echo -ne "${PROMPT}Please Enter Column $i Name : ${NC}"
		if ! read name; then
			return
		fi
		if [[ $name == *['!'@#\$%^\&*()-+\.\/]* ]]; then
			echo 
			echo -e "${RED} ! @ # $ % ^ () + . -  are not allowed!${NC}"
			continue
		fi
		if ! is_not_null $name ; then
			echo
			echo -e "${RED}Name Cannot Be Null!${NC}"
			continue
		fi
		if [[ "$name" = *" "* ]]; then
			echo 
			echo -e "${RED}Spaces Are Not Allowed!${NC}"
			continue
		fi
		if [[ "$name" = *:* ]]; then
			echo 
			echo -e "${RED}Colons Are Not Allowed!${NC}"
			continue
		fi
		break
	done
	# appending ti the array
	cols_names+=("$name")

	#Datatypes of the columns
	echo "datatypes are strings <str>, and integers <int>"
	echo -ne "${PROMPT}Enter Column $i datatype : ${NC}"
	if ! read dtype; then
		return
	fi
	
	#taking the datatype of the pk column
	while [[ true ]]; do
		case $dtype in
			str )
				break;;
			int )
				break;;
			alnum )
				break;;
			* )
				echo -ne "${RED}Please Enter A Supported Datatype : ${NC}"
				if ! read dtype; then
					return
				fi;;
		esac
	done
	#appending to the array
	cols_datatypes+=("$dtype")
done
#creating file representing the table
touch "./Databases/$1/$table_name"
#metadata of the table
echo "pk:${cols_names[0]}" > "./Databases/$1/${table_name}_Meta" # first line
for (( i = 0; i < $num_of_cols; i++ )); do
	echo "${cols_names[$i]}:${cols_datatypes[$i]}" >> "./Databases/$1/${table_name}_Meta"
done
echo
echo -e "${GREEN}Table $table_name created Successfully${NC}"
echo "Press Enter To continue!"
read
return