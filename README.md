# init-terraform

A sample repository that have the bare minimum TF code to demonstrate looping through all the AWS accounts in an Organization and execute terraform templates using AWS Codebuild.

This project utilize the AWSControlTowerExecution role created while deploying AWS Control Tower. This role can be change to something else if control tower is not enabled

To use this:
    1. Fork the repository
    2. Create a codebuild project and integrate with the github project 
    3. Create secrets in AWS secret manager for an IAM admin user. This credential is used to generate session token and creds to assume the role in the spoke accounts