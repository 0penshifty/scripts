#!/usr/bin/env bash
SECRET=$1
(oc get secret ${SECRET}-secrets -o yaml | yq '.data | map_values(@base64d)' | yq '.[]' | ~/bin/dotnet-appsettings-env -type compose -file /dev/fd/0; oc get configmap ${SECRET}-cm -o yaml | yq '.data'
) | sort | uniq

