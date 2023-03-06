#!/usr/bin/env bash

# Stop on command error
set -Eeuo pipefail

# Check if Terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "You need Terraform installed."
    exit 1
fi

# Check for backend config
backend_config_file="./backend.config"
if [ ! -f ${backend_config_file} ]; then
    echo "Missing file: $backend_config_file. Please, copy ./templates/$backend_config_file.template and fill all required data."
    exit 1
fi

# Init Terraform project
terraform init -backend-config=$backend_config_file
