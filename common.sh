#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/roboshop-shellscript"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
MONGODB_HOST=mongodb.devopsd88s.online
MYSQL_HOST=mysql.devopsd88s.online

mkdir -p $LOGS_FOLDER

echo "$(date "+%Y-%m-%d %H:%M:%S") | Script started executing at: $(date)" | tee -a $LOGS_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
        exit 1
    fi
}
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$(date "+%Y-%m-%d %H-%M-%S") $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$(date "+%Y-%m-%d %H-%M-%S") $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}
nodejs_setup(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling NodeJS Default version"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling NodeJs Default 20"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Install NodeJS"

    npm install &>>$LOGS_FILE ## you can write, if node js is install are not if not install , if yes install..
    VALIDATE $? "Install Dependenices"

}
java_setup(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"
    cd /app 
    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "Installing and Building $app_name"

    mv target/shipping-1.0.jar $app_name.jar 
    VALIDATE $? "Moving and Renaming $app_name"
}
app_setup(){
    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating system user"
    else 
        echo -e "Roboshop user already exist..$Y Skipping $N"
    fi
    #downloading app
    
    mkdir -p /app 
    VALIDATE $? "Creating app directroy"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOGS_FILE
    VALIDATE $? "Downloading $app_name code"

    cd /app
    VALIDATE $? "Moving to app directory" 

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$app_name.zip &>>$LOGS_FILE
    VALIDATE $? "unzip $app_name code"
}
systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Created systemctl service"

    systemctl daemon-reload
    systemctl enable $app_name &>>$LOGS_FILE
    systemctl start $app_name
    VALIDATE $? "starting and enabling $app_name"
}

app_restart_setup(){
    systemctl restart $app_name
    VALIDATE $? "Restarting $app_name"

}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script execute in: $G $TOTAL_TIME seconds $N" | tee -a $LOGS_FILE
}