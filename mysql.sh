#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MYSQL server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "starting MYSQL server"


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

<<com
[ ec2-user@ip-172-31-21-224 ~/shell-script-2 ]$ sudo sh mysql.sh
You are super user.
Installing mysql server..... SUCCESS
Enabling MYSQL server..... SUCCESS
starting MYSQL server..... SUCCESS
Please enter DB password:
Setting up MYSQL root password..... SUCCESS
com
