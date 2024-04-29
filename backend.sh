#!/bin/bash

source ./common.sh

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing NODEJS"

<<com
##Option-1
useradd expense &>>$LOGFILE
VALIDATE $? "Creating expense user"
## here useradd expense command is not idempotent so we need to handle this scenario
com


##Option-2
##To achive idempotent we follow below steps
id expense
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already exist...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE  
## -p is used to create directory if not exist otherwise uses the already existing app dir
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend application"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "extract backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing node js dependencies"

#source file path is your repository path in which the file is created.
cp /home/ec2-user/shell-script/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
## here we are giving the absolute path to avoid the errors basically.
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySql client"

echo "Please enter DB password: "
read -s mysql_root_password

##  mysql_root_password=ExpenseApp@1
mysql -h db.pspkdevops.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend service"
