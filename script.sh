
# Create an IAM use and store the creds in the parameter store 
# pass the variables to the codebuild project

aws_session_set() {
  # Sets: aws_access_key_id aws_secret_access_key aws_session_token
  local account=$1
  local role=${2:-$AWS_SESSION_ROLE}
  local accesskey=$3
  local secret=$4
  local name=${5:-aws-session-access}
  read -r aws_access_key_id \
          aws_secret_access_key \
          aws_session_token \
    <<<$(AWS_ACCESS_KEY_ID=$accesskey \
         AWS_SECRET_ACCESS_KEY=$secret \
         aws sts assume-role \
           --role-arn arn:aws:iam::$account:role/$role \
           --role-session-name "$name" \
           --output text \
           --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]')
  test -n "$aws_access_key_id" && return 0 || return 1
}

aws_session_run() {
  AWS_ACCESS_KEY_ID=$aws_access_key_id \
  AWS_SECRET_ACCESS_KEY=$aws_secret_access_key \
  AWS_SESSION_TOKEN=$aws_session_token \
    "$@"
}

aws_session_cleanup() {
  unset source_access_key_id source_secret_access_key source_session_token
  unset    aws_access_key_id    aws_secret_access_key    aws_session_token
}

# get the account ids from organization
region=$3
echo "excuting in region: $region"
export AWS_DEFAULT_REGION=$region
role='AWSControlTowerExecution'
accesskey=$1
echo $accesskey
secret=$2
echo $secret
accounts=$(aws organizations list-accounts \
             --output text \
             --query 'Accounts[].[JoinedTimestamp,Status,Id,Email,Name]' |
           grep ACTIVE |
           sort |
           cut -f3)
echo "$accounts"

for account in $accounts; do
  # Set up temporary assume-role credentials for an account/role
  # Skip to next account if there was an error.
  aws_session_set $account $role $accesskey $secret || continue

  # Sample command 1: Get the current account id (should match)
  this_account=$(aws_session_run \
                   aws sts get-caller-identity \
                     --output text \
                     --query 'Account')
  echo "Account: $account ($this_account)"

  # Sample command 2: List the S3 buckets in the account
  aws_session_run aws s3 ls
  echo "Using state bucket: nokram-tf-state-$account-$region in region: $region"
  aws_session_run terraform init -backend-config="bucket=nokram-tf-state-$account-$region" -backend-config="key=terraform-$account-$region.tfstate" -backend-config="region=$region" -backend=true -force-copy -get=true -input=false
  aws_session_run terraform apply -auto-approve
  echo Deleting the hidden terraform directory that contains the state bucket data
  rm -rf .terraform
  echo Listing the curent working directory
  ls -al
done
