#!/bin/bash

source ./common.sh

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing NginX"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

#source file path is your repository path in which the file is created.
cp /home/ec2-user/shell-script/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied expense path"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting Nginx"

