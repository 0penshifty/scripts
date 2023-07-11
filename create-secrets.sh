#!/usr/bin/env bash

TARGETENV=""
PROJECT=""
SOURCEFILE=""
CREATESECRETS=false
UPDATEPARAMTEMPLATE=false

# Function to display script usage
usage() {
        echo "Usage: $0 -e|--env <environment> -p|--project <project> [-c|--create] <file>"
        echo "Options:"
        echo "  -h, --help      Display this help message"
        echo "  -c, --create    Create secrets in Cloudtruth"
}


# Extract options and arguments
while [[ $# -gt 0 ]]; do
        case "$1" in
                -h|--help)
                        usage
                        exit 0
                        ;;
                -c|--create)
                        CREATESECRETS=true
                        shift
                        ;;
                -u|--update)
                        UPDATEPARAMTEMPLATE=true
			shift
			;;
                -e|--env)
                        TARGETENV="$2"
                        shift 2
                        ;;
                -p|--project)
                        PROJECT="$2"
                        shift 2
                        ;;
                *)
                        SOURCEFILE="$1"
                        shift
                        break
                        ;;
        esac
done

# Check for required arguments
if [[ -z "$TARGETENV" || -z "$PROJECT" || -z "$SOURCEFILE" ]]; then
        echo "Error: Required arguments missing."
        usage
        exit 1
fi

# Create Secrets if -c|--create flag is passed
if [[ "true" == "${CREATESECRETS:-false}" ]]; then
	(envsubst <<-EOF
	sed 's/: "/\t\x27/;s/"$/\x27/' ${SOURCEFILE} | \
	awk -F'\t' '{print "cloudtruth --env ${TARGETENV} --project common parameters set " \$1 " --value=" \$2}'
	EOF
	) | sh | sh
fi

# Publish the template data into a cloudtruth parameter
if [[ "true" == "${UPDATEPARAMTEMPLATE:-false}" ]]; then
	cut -d: -f1 ${SOURCEFILE} | awk '{print $1 ": \"{{ " $1 " }}\""}' | cloudtruth --env ${TARGETENV} --project ${PROJECT} parameters set -e true -i /dev/fd/0 ${PROJECT}-secret-data
fi

