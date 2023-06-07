#!/bin/bash

action=$1

# Check if an action parameter is provided
if [ -z "$action" ]; then
  echo "Please provide an action parameter: --stop, --start, or --destroy"
  exit 1
fi

# Function to stop all instances
stop_instances() {
  instance_ids=$(aws ec2 describe-instances --region eu-north-1 --query "Reservations[].Instances[?State.Name=='running'].InstanceId" --output text)
  
  if [ -z "$instance_ids" ]; then
    echo "No running instances found."
    exit 0
  fi

  echo "Stopping instances:"
  echo "$instance_ids"

  aws ec2 stop-instances --region eu-north-1 --instance-ids $instance_ids

  echo "Instances stopped successfully."
}

# Function to start all instances
start_instances() {
  instance_ids=$(aws ec2 describe-instances --region eu-north-1 --query "Reservations[].Instances[?State.Name=='stopped'].InstanceId" --output text)
  
  if [ -z "$instance_ids" ]; then
    echo "No stopped instances found."
    exit 0
  fi

  echo "Starting instances:"
  echo "$instance_ids"

  aws ec2 start-instances --region eu-north-1 --instance-ids $instance_ids

  echo "Instances started successfully."
}

# Function to destroy all instances
destroy_instances() {
  instance_ids=$(aws ec2 describe-instances --region eu-north-1 --query "Reservations[].Instances[].InstanceId" --output text)
  
  if [ -z "$instance_ids" ]; then
    echo "No instances found."
    exit 0
  fi

  echo "The following instances will be destroyed:"
  echo "$instance_ids"

  read -p "Are you sure you want to destroy these instances? (y/n) " confirm

  if [ "$confirm" == "y" ]; then
    aws ec2 terminate-instances --region eu-north-1 --instance-ids $instance_ids
    echo "Instances destroyed successfully."
  else
    echo "Aborted."
  fi
}

# Perform the requested action
case "$action" in
  --stop)
    stop_instances
    ;;
  --start)
    start_instances
    ;;
  --destroy)
    destroy_instances
    ;;
  *)
    echo "Invalid action parameter: $action"
    exit 1
    ;;
esac

