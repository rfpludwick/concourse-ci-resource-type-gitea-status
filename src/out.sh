#!/usr/bin/env bash

set -e

PAYLOAD="$(cat <&0)"

GITEA_PROTOCOL="$(jq --raw-output --monochrome-output '.source.protocol // ""' <<< "${PAYLOAD}")"
GITEA_HOST="$(jq --raw-output --monochrome-output '.source.host // ""' <<< "${PAYLOAD}")"
GITEA_USERNAME="$(jq --raw-output --monochrome-output '.source.username // ""' <<< "${PAYLOAD}")"
GITEA_PASSWORD="$(jq --raw-output --monochrome-output '.source.password // ""' <<< "${PAYLOAD}")"
REPOSITORY_PATH="$(jq --raw-output --monochrome-output '.params.repo // ""' <<< "${PAYLOAD}")"
BUILD_STATUS_PREFIX="$(jq --raw-output --monochrome-output '.params.build_status_prefix // empty // ""' <<< "${PAYLOAD}" | xargs)"
BUILD_STATE="$(jq --raw-output --monochrome-output '.params.build_state // ""' <<< "${PAYLOAD}")"
BUILD_STATUS_BRANCH_SUFFIX="$(jq --raw-output --monochrome-output '.params.build_status_branch_suffix // false // ""' <<< "${PAYLOAD}")"
BUILD_STATUS_DESCRIPTION="$(jq --raw-output --monochrome-output '.params.build_status_description // empty // ""' <<< "${PAYLOAD}" | xargs)"
BUILD_VARS=""

cd /tmp/build/put/"${REPOSITORY_PATH}"

REPOSITORY_SHA="$(git rev-parse HEAD)"
REPOSITORY_REMOTE="$(git remote get-url origin)"

re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+)$"

if [[ $REPOSITORY_REMOTE =~ $re ]]; then
    REPOSITORY_OWNER=${BASH_REMATCH[4]}
    REPOSITORY_NAME=$(basename "${BASH_REMATCH[5]}" .git)
else
	echo "Unable to determine repository owner and name" >&2
	exit 1
fi

if [[ -n "${BUILD_PIPELINE_INSTANCE_VARS}" ]]; then
	BUILD_VARS="?"

	COUNTER=0

	while IFS= read -r line; do
		if [[ $COUNTER -gt 0 ]]; then
			BUILD_VARS+="&"
		fi

		COUNTER=$COUNTER+1

		BUILD_VARS+="${line}"
	done < <( echo "${BUILD_PIPELINE_INSTANCE_VARS}" | jq --raw-output --monochrome-output 'to_entries|map("vars.\(.key)=%22\(.value|tostring|@uri)%22")|.[]' )
	# 	fi
	# fi
fi

if [[ "${BUILD_STATUS_BRANCH_SUFFIX}" = "false" ]]; then
	BUILD_STATUS_BRANCH_SUFFIX=""
else
	while IFS= read -r line; do
		if [[ ! $line =~ $re ]]; then
			BUILD_STATUS_BRANCH_SUFFIX="${line#refs/heads}"

			break
		fi
	done < <( git rev-parse --symbolic --all )
fi

if [[ -n "${BUILD_STATUS_DESCRIPTION}" ]]; then
	BUILD_STATUS_DESCRIPTION="\"description\": \"${BUILD_STATUS_DESCRIPTION}\","
fi

NETRC_FILE="$(mktemp)"

echo "machine ${GITEA_HOST} login ${GITEA_USERNAME} password ${GITEA_PASSWORD}" > "${NETRC_FILE}"

curl \
	--silent \
	--show-error \
	--netrc-file "${NETRC_FILE}" \
	--header "Content-Type: application/json" \
	--request POST \
	--data "{
			\"context\": \"${BUILD_STATUS_PREFIX}${BUILD_JOB_NAME}${BUILD_STATUS_BRANCH_SUFFIX}\",
			${BUILD_STATUS_DESCRIPTION}
			\"state\": \"${BUILD_STATE}\",
			\"target_url\": \"${ATC_EXTERNAL_URL}/teams/${BUILD_TEAM_NAME}/pipelines/${BUILD_PIPELINE_NAME}/jobs/${BUILD_JOB_NAME}/builds/${BUILD_NAME}${BUILD_VARS}\"
		}" \
	"${GITEA_PROTOCOL}""${GITEA_HOST}"/api/v1/repos/"${REPOSITORY_OWNER}"/"${REPOSITORY_NAME}"/statuses/"${REPOSITORY_SHA}" > /dev/null

echo "{\"version\":{\"ref\":\"${REPOSITORY_SHA}\"}}"
exit 0
