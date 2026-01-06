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
  printf "   ____ _     ___ ___  _   _ _____ __  __    _    _   _ ___    _    \n";
  printf "  / ___| |   |_ _/ _ \| | | | ____|  \/  |  / \  | \ | |_ _|  / \   \n";
  printf " | |   | |    | | | | | | | |  _| | |\/| | / _ \ |  \| || |  / _ \  \n";
  printf " | |___| |___ | | |_| | |_| | |___| |  | |/ ___ \| |\  || | / ___ \ \n";
  printf "  \____|_____|___\___/ \___/|_____|_|  |_/_/   \_\_| \_|___/_/   \_\ \n";
  printf "${NC}";

  printf "\n"
}
