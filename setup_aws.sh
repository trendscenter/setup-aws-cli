#!/bin/bash

# This script requests AWS CLI MFA credentials and saves them as 
# environment variables to a local file.

function load_env {
    set -a
    [ -f .env ] && . .env
    set +a
}

usage() { echo "Usage: $0 [-v] -t mfa_code" 1>&2; exit 1; }

VERBOSE=false

# Parse command line arguments 

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -t|--token) TOKEN="$2"; shift ;;
    -v|--verbose) VERBOSE=true ;;
    *) echo "Unknown parameter passed: $1"; usage ;;
  esac
  shift
done

if [ -z "${TOKEN+x}" ]
then
  echo "MFA token not set"
  usage
  exit 1
fi

load_env

if $VERBOSE
then
  echo
  echo "Local variables"
  echo "---------------"
  echo "ARN: ${ARN}"
  echo "TOKEN: ${TOKEN}"
  echo "ENV_FILE: ${ENV_FILE}"
  echo
fi

# Request credentials from AWS
aws_command="aws sts get-session-token --serial-number ${ARN} --token-code ${TOKEN}" 

command="${aws_command}"

if $VERBOSE
then
  printf "Command: \n %s\n" "$command"
fi

echo
echo "Requesting credentials..."
creds=`eval " $command"`

if [ -z "${creds}" ]
then
  echo "ERROR: Request failed"
  exit 0
fi

echo "Credentials received!"

if $VERBOSE
then
  printf "Credentials: \n %s\n" "$creds"
fi

# Parse response
aws_access_key=`echo $creds | jq '.Credentials.AccessKeyId' | sed 's/"//g'`
aws_secret_access_key=`echo $creds | jq '.Credentials.SecretAccessKey' | sed 's/"//g'`
aws_session_token=`echo $creds | jq '.Credentials.SessionToken' | sed 's/"//g'`
expiration=`echo $creds | jq '.Credentials.Expiration' | sed 's/"//g'`

# Save credentials to environment variables in separate file
if $VERBOSE
then
  echo
  echo "Environment variables will be saved to ${ENV_FILE} as follows:"
  echo "AWS_ACCESS_KEY_ID: ${aws_access_key}"
  echo "AWS_SECRET_ACCESS_KEY: ${aws_secret_access_key}"
  echo "AWS_SESSION_TOKEN: ${aws_session_token}"
fi

echo "export AWS_ACCESS_KEY_ID=$aws_access_key" > $ENV_FILE
echo "export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key" >> $ENV_FILE
echo "export AWS_SESSION_TOKEN=$aws_session_token" >> $ENV_FILE

echo
echo "Finished!"
echo
echo "Your credentials will expire on ${expiration}"
echo
echo "Type 'source ${ENV_FILE}' to export environment variables"
echo
echo "After you are done using the AWS CLI, close your terminal"
echo "or unset your environment variables by typing 'source unset.sh'."
echo
