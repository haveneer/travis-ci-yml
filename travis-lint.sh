#!/usr/bin/env bash
set -euEo pipefail

# ${X-} returns empty not "unbound variable" due to `set -u`
FILE=${1-}

if [[ -z "$FILE" ]]; then
  echo "Usage: $0 travis-config-file"
  exit 1
fi

CID=$(docker container ls -q -a --filter=name=travis-lint)
if [[ -z "$CID" ]]; then
    echo "Starting travis lint container"
    docker run -d --name travis-lint -p 9292:9292 haveneer/travis-ci-yml > /dev/null
else
    docker start travis-lint > /dev/null
fi

while ! curl -s "http://localhost:9292/v1" -o /dev/null ; do
  sleep 0.1 # wait for 1/10 of the second before check again
done

curl -sS -X POST --data-binary @${FILE} "http://localhost:9292/v1/parse" | jq --raw-output '.full_messages[]'

docker stop travis-lint > /dev/null