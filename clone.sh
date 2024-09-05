#!/usr/bin/env bash
# Get the $DP_AUTH_TOKEN
if [ -z "$DP_AUTH_TOKEN" ]; then
  echo "Error: DP_AUTH_TOKEN is empty." >&2
  exit 1
fi

# Get the $DP_SERVER_URL
if [ -z "$DP_SERVER_URL" ]; then
  DP_SERVER_URL="https://api.distributed.press" 
fi

# get first CLI argument as the site
site=$1 
 
# set the variable destination to the site
destination="$site" 

# if there is a second cli flag, set destination to it
if [ $# -gt 1 ]; then  
    destination="$2" 
fi

# make a folder for #destination
mkdir -p "$destination"

wget2 \
  --random-wait \
  --retry-on-http-error=503,504,429 \
  --compression=identity,gzip,br \
  --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/119.0" \
  --mirror \
  --page-requisites \
  --convert-links \
  --adjust-extension \
  --continue \
  --no-host-directories \
  --directory-prefix=$destination \
  "https://${site}"

# make a tarball out of the destination folder
tar -cf "${destination}.tar.gz" "$destination/"

dp_endpoint="${DP_SERVER_URL}/v1/sites/${destination}"

echo "Checking to see if the site has been created"

curl \
  -X GET \
  --fail \
  -H "Authorization: Bearer ${DP_AUTH_TOKEN}" \
  $dp_endpoint
if [ $? -eq 0 ]; then
  echo "Site already created" 
else
  echo "Site not created: Initializing site"

  create_data="{\"public\": true, \"domain\":\"${destination}\",\"protocols\":{\"http\": true,\"hyper\": true,\"ipfs\": true}}"

  curl \
    -X POST \
    --fail \
    -H "Authorization: Bearer ${DP_AUTH_TOKEN}" \
    -H "content-type: application/json" \
    --data $create_data \
    $dp_endpoint
    if [ $? -eq 0 ]; then
      echo "Unable to create site." >&2
      exit 2
    fi
fi


echo "Uploading to ${dp_endpoint}"

# send a curl POST request to DP_SERVER_URL with the bearer token in DP_AUTH_TOKEN, upload the tarball as an attachment
curl -X PUT \
  --fail \
  -H "Authorization: Bearer ${DP_AUTH_TOKEN}" \
  -F "upload=@${destination}.tar.gz" \
  $dp_endpoint

# TODO: Cleanup
rm -rf "./${destination}*"
