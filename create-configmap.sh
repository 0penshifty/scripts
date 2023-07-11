#!/usr/bin/env bash
shopt -s extglob

#!/usr/bin/env bash

TARGETENV=""
PROJECT=""
SOURCEFILE=""

# Function to display script usage
usage() {
        echo "Usage: $0 -e|--env <environment> -p|--project <project> <file>"
        echo "Options:"
        echo "  -h, --help      Display this help message"
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


case "${PROJECT}" in
        *-datafabric|*-dbmigrate)
                (cat ${SOURCEFILE}; oc get deployment/${PROJECT} -o yaml | yq '.spec.template.spec.containers[].env[] | select(.name == "Serilog__WriteTo__0__Args__source" or .name == "Serilog__WriteTo__0__Args__service" or .name=="ServiceOptions__Migration__MigrateOnStartup") | {.name: .value | . style="double"}') | sort | uniq | cloudtruth --env ${TARGETENV} --project ${PROJECT} parameter set ${PROJECT}-configmap-data -i /dev/fd/0
                ;;
        *)
                cloudtruth --env ${TARGETENV} --project ${PROJECT} parameter set ${PROJECT}-configmap-data -i ${SOURCEFILE}
                ;;
esac

