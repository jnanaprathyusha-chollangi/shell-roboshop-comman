#!/bin/bash

source ./common.sh

app_name=mysql

check_root


dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "installing mysql server"

systemctl enable mysqld &>>$LOGS_FILE
VALIDATE $? "Enabling the mysql"

systemctl start mysqld  &>>$LOGS_FILE
VALIDATE $? "starting the mysql"

#get the password from the root user
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setup root password"

print_total_time