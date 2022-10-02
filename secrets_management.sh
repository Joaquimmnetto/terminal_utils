export SECRETS_PRIVATE_KEY="$HOME/secrets.pem.private" 
export SECRETS_PUBLIC_KEY="$HOME/secrets.pem.public" 
export SECRETS_BASE_DIR="$HOME/.config/local_secrets"

add_local_secret() {
  local key=$1
  local secret=$2
  local public_key=$SECRETS_PUBLIC_KEY
  local secrets_dir=$SECRETS_BASE_DIR
  local target_secret_file="$secrets_dir/$key"
  
  if [ -z "$key" ]; then
    echo "secret key must not be empty"
    return 1
  fi
  if [ -z "$secret" ]; then
    echo "secret value must not be empty"
    return 1
  fi
  echo $secret | openssl pkeyutl -encrypt -pubin -inkey $public_key > $target_secret_file
}

local_secret() {
  local key=$1
  local private_key=$SECRETS_PRIVATE_KEY
  local secrets_dir=$SECRETS_BASE_DIR
  local target_secret_file="$secrets_dir/$key"
  
  if [ -z "$key" ]; then
    echo "secret key must not be empty"
    return 1
  fi
  openssl pkeyutl -decrypt -inkey $private_key -in $target_secret_file
}

aws_secret() {
  #only execute saml2aws if token is expired
  #saml2aws login -a atlas-admin && export AWS_PROFILE=atlas-admin
  local secret_name=$1
  local secret=$(aws secretsmanager get-secret-value --secret-id $secret_name --output json | jq -r .SecretString)
  echo $secret
}

delete_secret() {
    rm "$SECRETS_BASE_DIR/$1"
}