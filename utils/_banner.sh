#!/bin/bash
#
# Print banner art.

#######################################
# Print a board. 
# Globals:
#   BG_BROWN
#   NC
#   WHITE
#   CYAN_LIGHT
#   RED
#   GREEN
#   YELLOW
# Arguments:
#   None
#######################################
print_banner() {

  clear

  printf "\n\n"

  printf "${GREEN}";
  printf "  ____ _     ___ ___  _   _ _____ __  __    _    _   _ _    _    \n";
  printf " / ___| |   |_ _/ _ \| | | | ____|  \/  |  / \  | \ | | |  / \   \n";
  printf "| |   | |    | | | | | | | |  _| | |\/| | / _ \ |  \| | | / _ \  \n";
  printf "| |___| |___ | | |_| | |_| | |___| |  | |/ ___ \| |\  | |/ ___ \ \n";
  printf " \____|_____|___\__\_\\___/|_____|_|  |_/_/   \_\_| \_|_/_/   \_\\\n";
  printf "${NC}";

  printf "\n"
}
