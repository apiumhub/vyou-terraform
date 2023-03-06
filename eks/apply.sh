#!/usr/bin/env bash

# Stop on command error
set -Eeuo pipefail

# Check if Terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "You need Terraform installed."
    exit 1
fi

./init.sh

# Check for project.tfvars
vars_file="./project.tfvars"
if [ ! -f ${vars_file} ]; then
    echo "Missing file: $vars_file. Check variables.tf and add create your environment config in $vars_file."
    exit 1
fi

# Other needed files
mandatory_files=( "./cert.pem" "./chain.pem" "./fullchain.pem" "./key.pem" "./nginx.json")
for mandatory_file in "${mandatory_files[@]}"
do
    if [ ! -f ${mandatory_file} ]; then
        echo "Missing file: $mandatory_file."
        exit 1
    fi
done

# Plan or apply
PS3='Would you like to only plan or apply the new Terraform config? '
options=("Plan" "Apply" "Exit")
select opt in "${options[@]}"
do
    selected_provider=$opt
    case $opt in
        "Plan")
            terraform plan -var-file=$vars_file
            break
            ;;
        "Apply")
            terraform apply -var-file=$vars_file
            break
            ;;
        "Exit")
            exit 0
            ;;
        *) echo "Invalid option: $REPLY";;
    esac
done
