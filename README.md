# AWS Command Line MFA Set up                                                                                                                
These scripts are wrappers for the AWS command-line interface (CLI) multifactor authentication (MFA) setup procedure, which can be found [here](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/). Using the AWS CLI with an MFA device is a common use case, but the procedure requires a lot of manual information retrieval, copying, and pasting. These scripts are meant to ease the process. 

## Usage

1. Set up `.env` file
  - Start with `.env.example` as a template.
  
    `cp .env.example .env`
  - Fill in your MFA ARN code for the `ARN` variable. This can be found on your security credentials page on AWS ([here](https://console.aws.amazon.com/iam/home?#/security_credentials)). The ARN code is the Assigned MFA device under the Multi-factor authentication (MFA) section.
    - e.g., `arn:aws:iam::111122223333:mfa/username`
  - If you like, you can change the filename where the environment variables will be stored as well. This is stored as the `ENV_FILE` variable.
  - Save the file.

2. Run the script
  - Open your MFA device and find your 6-digit code (e.g., 123456)
  - Run the script in one of the following ways:

    `bash setup_aws.sh -t 123456`

    `bash setup_aws.sh --token 123456`

    `bash setup_aws.sh -v -t 123456`

    `bash setup_aws.sh --verbose --token 123456`

  - This will request your temporary credentials from AWS, which must be set as environment variables before you can use the CLI.

3. Set environment variables
  - Set the environment variables fetched by the script

    `source envs.sh`
    
    (or whatever your `ENV_FILE` is) 

4. Run your AWS CLI commands
  - e.g., `aws s3 ls` 

5. Unset your environment variables or close your shell

    `source unset.sh`

## Dependencies

1. You must have an AWS MFA device set up. 
2. You must have an AWS CLI access key set up. This can be done on your AWS security credentials page.
3. Install [jq](https://stedolan.github.io/jq/download/), a command-line utility that handles JSON.
