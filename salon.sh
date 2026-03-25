#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Bestest Salon ~~~~~\n"

echo -e "\nWelcome to my Salon!\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWhich service would you like to schedule today?"
  echo -e "\n1) Haircut\n2) Shampoo\n3) Color\n4) Shave"
  read SERVICE_ID_SELECTED

  SERVICE_ID=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_ID ]]
  then
    MAIN_MENU "Please enter a valid selection"
  else
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    echo -e "\nPlease enter your phone number: "
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nA new customer! What is your name?"
      read CUSTOMER_NAME
      ADD_CUSTOMER=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like for your$SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    ADD_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi 
}


MAIN_MENU


