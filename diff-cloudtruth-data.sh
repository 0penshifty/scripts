  ctenv="$1"
  for project in `cloudtruth project list -f json | jq -r '.project[] | select(.Parent == "common") | .Name' | egrep '^segmentexplorer$' | tr '\n' ' '`; do
    echo "----- ${project}-secret-data -----"
    DIFFS=$(diff <(cloudtruth --project ${project} --env ${ctenv} parameters get --as-of stable ${project}-secret-data) <(cloudtruth --project ${project} --env ${ctenv} parameters get ${project}-secret-data) | egrep '^>' | sed 's/^> //')

    if [[ -n "$DIFFS" && "$DIFFS" != "null" ]]; then
      echo "${DIFFS}" | yq -o json | jq '. | map_values(.[0:8] + "<Redacted>")' | yq -P
    else
      echo "No delta"
    fi

    echo "----- ${project}-configmap-data -----"
    DIFFS=$(diff <(cloudtruth --project ${project} --env ${ctenv} parameters get --as-of stable ${project}-configmap-data) <(cloudtruth --project ${project} --env ${ctenv} parameters get ${project}-configmap-data) | egrep '^>' | sed 's/^> //')
    if [[ -n "$DIFFS" && "$DIFFS" != "null" ]]; then
      echo "${DIFFS}" | yq -P
    else
      echo "No delta"
    fi
  done
}
