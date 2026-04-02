#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

PRINT_FORMATTED_RESULT()
{
  if [[ -z $1 ]]
  then
    echo "I could not find that element in the database."
  else
    IFS="|" read -ra element <<< "$1"
    echo -e "The element with atomic number ${element[1]} is ${element[3]} (${element[2]}). It's a ${element[7]}, with a mass of ${element[4]} amu. ${element[3]} has a melting point of ${element[5]} celsius and a boiling point of ${element[6]} celsius."
  fi
}

SEARCH_DATABASE()
{
  column=$1
  data=$2

  element="$($PSQL "select * from elements inner join properties using(atomic_number) inner join types using(type_id) where $column='$data';")"

  PRINT_FORMATTED_RESULT $element

}

CHECK_ARGUMENT_TYPE()
{
  case "$1" in
    [0-9])
      SEARCH_DATABASE "atomic_number" $1
      ;;
    [a-zA-Z]|[a-zA-Z][a-zA-Z])
      SEARCH_DATABASE "symbol" $1
      ;;
    *)
      SEARCH_DATABASE "name" $1
      ;;
esac

}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  CHECK_ARGUMENT_TYPE $1
fi


