#!/bin/bash
set -ue -o pipefail

set -x

declare -r ref=${GITHUB_REF_NAME}
declare -r owner=${GITHUB_REPOSITORY_OWNER}

declare -r bundleDir=$(mktemp -d) 
declare -r outputFile=release-bundle.zip

mkdir -vp code

jq -r --arg ref "${ref}" '.[$ref] | keys[] as $k | "\($k) \(.[$k])"' bundle.json | while read repoName repoTag
do
  git clone --depth=1 https://github.com/${owner}/${repoName} code/${repoName}
  (
    cd code/${repoName}
    git fetch --depth=1 origin tag ${repoTag}
    git archive ${repoTag} -o ${bundleDir}/${repoName}-${repoTag//./_}.zip 
  )
done

zip -j ${outputFile} ${bundleDir}/*.zip
