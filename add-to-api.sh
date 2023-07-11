
set -x
for i in customer datadesigner gatekeeper interchange portauthority shipyard storage; do
  for x in dev-cc dev-use dev-use test-cc prod-use prod-cc prod-ne ephemeral; do
    cloudtruth --env ${x} --project ${i}-worker parameter get ${i}-worker-configmap-data | yq '.Serilog__MinimumLevel__Override__Grpc = "Warning"' |  yq '."Serilog__MinimumLevel__Override__Symend.DataFabric.Grpc.Client" = "Warning"' | yq '."Serilog__MinimumLevel__Override__Symend.DataFabric.Grpc.Client.Interceptors" = "Warning"' | sort | cloudtruth --env ${x} --project ${i}-worker parameter set ${i}-worker-configmap-data -i /dev/fd/0
  done
done


