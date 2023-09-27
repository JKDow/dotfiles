#!/bin/bash

# Define the location of your virtual environment and Python script
VENV_DIR="./.venv"
PYTHON_SCRIPT="./stow_manager/stowman.py"

# Define the Python command to be used
PYTHON_CMD="python3"

# Check for a command argument (either 'stow' or 'unstow')
if [ "$#" -ne 1 ] || [[ ! "$1" =~ ^(stow|unstow)$ ]]; then
    echo "Usage: $0 <stow|unstow>"
    exit 1
fi

# Create a virtual environment if it does not exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    $PYTHON_CMD -m venv "$VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Install the 'toml' package if it is not installed
pip show toml > /dev/null || pip install toml

# Run the Python script with the given command
$PYTHON_CMD "$PYTHON_SCRIPT" "$1"

# Deactivate the virtual environment
deactivate


