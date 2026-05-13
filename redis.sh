#!/bin/bash 

source ./common.sh 

check_root

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disabling the redis"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enabling redis:7"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "Installing the redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "Enabling the redis"

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Starting the redis"

print_total_time