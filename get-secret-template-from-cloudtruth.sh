#!/usr/bin/env bash
#set -x
export TARGETENV=""
export PROJECT=""
export TAG=""

# Function to display script usage
usage() {
        echo "Usage: $0 -e|--env <environment> -p|--project <project> [-t|--tag <tag>]"
}


# Extract options and arguments
while [[ $# -gt 0 ]]; do
        case "$1" in
                -h|--help)
                        usage
                        exit 0
                        ;;
                -e|--env)
                        TARGETENV="$2"
                        shift 2
                        ;;
                -p|--project)
                        PROJECT="$2"
                        shift 2
                        ;;
                -t|--tag)
                        TAG="&tag=$2"
                        shift 2
                        ;;
        esac
done

# Check for required arguments
if [[ -z "$TARGETENV" || -z "$PROJECT" ]]; then
        echo "Error: Required arguments missing."
        usage
        exit 1
fi


export PROJECTKEY=$(curl -s --header "Content-Type: application/json" --header "Authorization: Api-Key ${CLOUDTRUTH_API_KEY}" --request GET https://api.cloudtruth.io/api/v1/projects/ -o -| jq -r '.results[] | select( .name == env.PROJECT ).id')

export ENVIRONMENTKEY=$(curl -s --header "Content-Type: application/json" --header "Authorization: Api-Key ${CLOUDTRUTH_API_KEY}" --request GET "https://api.cloudtruth.io/api/v1/environments/" -o - | jq -r '.results[] | select (.name == env.TARGETENV).id')

curl -v --header "Authorization: Api-Key ${CLOUDTRUTH_API_KEY}" --header "accept: application/json" --request 'GET' "https://api.cloudtruth.io/api/v1/projects/${PROJECTKEY}/parameters/?environment=${ENVIRONMENTKEY}&evaluate=false&immediate_parameters=true&mask_secrets=false&name__iexact=${PROJECT}-secret-data${TAG}" 2>/dev/null | jq -r '.results[0].values_flat[0].value'

