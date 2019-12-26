#!/bin/sh

# Prompt for bash script
echo "*******************************************************"
echo -e "This Script is for \033[31;40mSingle deafult AWS IAM User only!\033[0m \nPlease make sure you're in correct AWS environment"
echo "*******************************************************"


# Prompt for AWS ARN
echo -e "\033[1m\033[32mInfo:\033[0m Enter AWS Assigned MFA device ARN from the console(Security credentials -> Assigned MFA device) here \nYou can find Your \033[31;40mAssigned MFA device ARN\033[0m \033[32m(https://console.aws.amazon.com/iam/home?region=us-east-2#/security_credentials):\033[0m\n"
read -p "Enter your AWS Assigned MFA device ARN here: " serialnumber
while [[ -z "$serialnumber" ]]; do 
    read -p "Plase make sure your arn IS NOT empty! Re-enter here:" serialnumber
done
echo -e "Input serial-number is : \033[1m\033[32m$serialnumber\033[0m"

# Prompt for MFA
read -p "Enter your AWS MFA Virutal Device token here:" tokencode

while [[ -z "$tokencode" ]]; do 
    read -p "Plase make your tokencode IS NOT empty! Re-enter here:" tokencode
done

# Run AWS Token Command
# https://docs.aws.amazon.com/cli/latest/reference/sts/get-session-token.html
# 86400s 24h

aws_credentials=$(aws sts get-session-token --serial-number "$serialnumber" --token-code "$tokencode" --duration-seconds 86400 --output json)

jq="jq --exit-status --raw-output"
# " -r / --raw-output"  If the filter’s result is a string then it will be written directly to standard output rather than being formatted as a JSON string with quotes.
# "-e / --exit-status" Sets the exit status of jq to 0 if the last output values was neither false nor null\

AWS_ACCESS_KEY_ID=$(echo "$aws_credentials" | $jq '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$aws_credentials" | $jq '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "$aws_credentials" | $jq '.Credentials.SessionToken')

# export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo -e "\033[31;40mFailed to get credentials for user, please re-login again!\033[0m"
else
    # Running without source
    
    echo -e "\nRunning fowllowing commands below line by line if you run the script without \033[31;42msource\033[0m" 
    echo -e "*******************************************************"
    echo -e "export AWS_ACCESS_KEY_ID=\033[1m\033[32m$AWS_ACCESS_KEY_ID\033[0m"  
    echo -e "export AWS_SECRET_ACCESS_KEY=\033[1m\033[32m$AWS_SECRET_ACCESS_KEY\033[0m"  
    echo -e "export AWS_SESSION_TOKEN=\033[1m\033[32m$AWS_SESSION_TOKEN\033[0m" 
    echo -e "*******************************************************"
    # Running in source 
    export "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" 
    export "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" 
    export "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN"
    echo -e "This aws session will expired in \033[31;40m24h!\033[0m, Happy AWSing"
fi






# aws sts get-session-token --serial-number  arn:aws:iam::220821228677:mfa/MFA_test --token-code 059196