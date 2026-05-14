#!/bin/bash

source ./comman.sh


app_name=rabbitmq
check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Added rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $> "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOGS_FILE
systemctl start rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Enabling nd starting the rabbitmq"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Created users and given permissions"