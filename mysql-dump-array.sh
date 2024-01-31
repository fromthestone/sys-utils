#!/usr/bin/env bash
#
# MySQL Dump Backup
#
# Copyright (C) 2010-2013 Matteo Dalmasso <contact@matteodalmasso.com>
#
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#### Start set section ####

# Define Array of DB names
# Add a index/value string each DB you want backup
DB_NAME[0]="DB1"
DB_NAME[1]="DB2" 
DB_NAME[2]="DB3"

# Define Array of DB Usernames
# Add a index/value string each username
DB_USER[0]="USER1"
DB_USER[1]="USER2"
DB_USER[2]="USER3"

# Define Array of DB Password
# Add a index/value string each password
DB_PASS[0]=""
DB_PASS[1]=""
DB_PASS[2]=""

# Set up time zone
# Please refer to /usr/share/zoneinfo to set up the right one
export TZ=Asia/Hong_Kong

# Define Backup Prefix name
# Optional 
#FNAME="MySQL_Backup_"
FNAME=""
# Set up Directory for backups
BCK_DIR=$HOME"/Mysql_backups/"

# Define here all Mysqldump options. I remind to this page for alla advises and warnings: http://dev.mysql.com/doc/refman/5.1/en/mysqldump.html
#Dump Option
DUMP="--opt"

#### End set up section ####

umask 077

BIN_CHECK="mysqldump mysql gzip"
count=${#DB_NAME[@]}
index=0

########################################
######## Subroutines definitions########
########################################

## Main Backup Function
backup ()
{
while [ "$index" -lt "$count" ]; do
	
	#Check DB, User, Pass
if test=$(mysql -u ${DB_USER[$index]} -p${DB_PASS[$index]} -e "use "${DB_NAME[$index]} 2>&1); then

	#If the command below goes fine execute backup
	mysqldump $DUMP ${DB_NAME[$index]} -u ${DB_USER[$index]} -p${DB_PASS[$index]} | gzip - > $BCK_DIR$FNAME${DB_NAME[$index]}"_"$(date +"%y%m%d%H%M%S")".sql.gz" 
else

echo -e "An error occurred:" $test
	
fi
let "index++"
done
}

#####################
###### @ Work! ######
#####################

## Check the shell
if [ -z "$BASH_VERSION" ]; then
	echo -e "Error: this script requires BASH shell!"
     exit 1
fi 

# DEPENDENCIES CHECK
for i in $BIN_CHECK; do
	which $i &> /dev/null
if [ $? -ne 0 ]; then
    echo -e\n "Error: Required program could not be found: $i"
   exit 1
    fi
done




if [ -d $BCK_DIR ]; then
	backup
else 
	`mkdir $BCK_DIR`
	backup
fi 
