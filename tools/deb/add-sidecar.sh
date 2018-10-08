#!/bin/bash
while getopts "i:p:n:a:" opt; do
  case ${opt} in
    i)
      NETWORK_CONTAINER_ID=${OPTARG}
      ;;
    p)
      POD_NAME=${OPTARG}
      ;;
    n)
      POD_NAMESPACE=${OPTARG}
      ;;
    a)
      POD_IP=${OPTARG}
      ;;
  esac
done

function get_pod_svc_name() {
    IFS=-
    pod_name_part=($POD_NAME)
    echo ${pod_name_part[0]}
}

function get_pod_deploy_name() {
    IFS=-
    pod_name_part=($POD_NAME)
    echo ${pod_name_part[0]}-${pod_name_part[1]}
}

SVC_NAME=$(get_pod_svc_name $POD_NAME)
DEPLOY_NAME=$(get_pod_deploy_name $POD_NAME)
CONTAINER_NAME=${DEPLOY_NAME}-istio-proxy


sudo docker run -d --name $CONTAINER_NAME --network=container:$NETWORK_CONTAINER_ID --user=1337 -e "POD_NAME=${POD_NAME}" -e "POD_NAMESPACE=${POD_NAMESPACE}" -e "INSTANCE_IP=${POD_IP}" -e "ISTIO_META_POD_NAME=${POD_NAME}" -e "ISTIO_META_INTERCEPTION_MODE=REDIRECT"  --tmpfs=/etc/istio/proxy:uid=1337 --volume=/opt/certs:/etc/certs/: docker.io/baodongli/proxyv2:1.0.0 proxy sidecar --configPath /etc/istio/proxy --binaryPath /usr/local/bin/envoy --serviceCluster ${SVC_NAME}.${POD_NAMESPACE} --drainDuration 2s --parentShutdownDuration 3s --discoveryAddress istio-pilot.istio-system:15011 --zipkinAddress zipkin.istio-system:9411 --connectTimeout 1s --proxyAdminPort "15000" --controlPlaneAuthPolicy MUTUAL_TLS --statusPort "15020" --applicationPorts ""
