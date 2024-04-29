#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MYSQL server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "starting MYSQL server"


<<com

##OPTION-1 - start     hardcoded password and not idempotent

#mysql_secure_installation --set-root-pass ExpenseApp@1
#VALIDATE $? "setting up root password for MYSQL server"

##OPTION-1 - end


#below code is useful to achive the idempotent nature
##OPTION-2 -start hardcode the password but idempotent achived
## below command is used to check whether username & password are configured or not for the database
## mysql -h db.pspkdevops.online -uroot -pExpenseApp@1 -e 'show databases'
mysql -h db.pspkdevops.online -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
    VALIDATE $? "Setting up MYSQL root password"
else
    echo -e "MYSQL root password is already setup...$Y SKIPPING $N"
fi

##OPTION-2 - end

com

##OPTION-3
## instead of hardcode the password we can pass it as argument while running the script
echo "Please enter DB password: "
read -s mysql_root_password

mysql -h db.pspkdevops.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "Setting up MYSQL root password"
else
    echo -e "MYSQL root password is already setup...$Y SKIPPING $N"
fi

