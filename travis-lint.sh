#!/usr/bin/env bash
set -euEo pipefail

# ${X-} returns empty not "unbound variable" due to `set -u`
FILE=${1-}

if [[ -z "$FILE" ]]; then
  echo "Usage: $0 travis-config-file"
  exit 1
fi

CID=$(docker container ls -q --filter=name=travis-lint)
if [[ -z "$CID" ]]; then
    docker run -d --name travis-lint -p 9292:9292 test/travis
fi

curl -sS -X POST --data-binary @${FILE} "http://localhost:9292/v1/parse" | jq --raw-output '.full_messages[]'
