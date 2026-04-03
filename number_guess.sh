#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username when starting the script

echo "Enter your username: "
read user_entry

# Search database for username and respond whether user exists or not
player_id="$($PSQL "select player_id from player where username='$user_entry';")"

if [[ -z $player_id ]]
then
  echo "Welcome, $user_entry! It looks like this is your first time here."
  
  #add username to the database
  add_user_result="$($PSQL "insert into player (username) values('$user_entry');")"

  #get player id to user for storing games
  player_id="$($PSQL "select player_id from player where username='$user_entry';")"
else
  # If user exists, find how many games they've played and how many guesses their fastest game took.
  games_played="$($PSQL "select count(*) from games where player_id=$player_id;")"
  best_game="$($PSQL "select min(number_of_guesses) from games where player_id=$player_id;")"

  # Change the wording if the user has only played one game and/or won the game in one guess.
  if [[ $games_played -eq 1 ]]
  then
    game_word="game"
  else
    game_word="games"
  fi

   if [[ $best_game -eq 1 ]]
  then
    guess_word="guess"
  else
    guess_word="guesses"
  fi

  username="$($PSQL "select username from player where player_id=$player_id;")"
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# Create Number guessing game loop
number_to_guess=$(( $RANDOM % 1000 + 1 ))
guesses=0
user_guess=""

while [[ "$user_guess" != "$number_to_guess" ]]
do
  echo "Guess the secret number between 1 and 1000:"
  read user_guess
  ((guesses += 1))
  if [[ ! "$user_guess" =~ ^-?[0-9]+$ ]] 
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $user_guess -lt $number_to_guess ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $user_guess -gt $number_to_guess ]]
    then
      echo "It's lower than that, guess again:"
    fi
  fi
done

if [[ $guesses -eq 1 ]]
  then
    guess_word="try"
  else
    guess_word="tries"
  fi

echo "You guessed it in $guesses $guess_word. The secret number was $number_to_guess. Nice job!"

# Store the game result into the database
player_id="$($PSQL "insert into games(player_id, number_of_guesses) values($player_id, $guesses);")"
