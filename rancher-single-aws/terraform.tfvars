# Amazon AWS Access Key
aws_access_key = ""
# Amazon AWS Secret Key
aws_secret_key = ""
# Amazon AWS Key Pair Name
ssh_key_name = "cyri-demo"
# Region where resources should be created
region = "eu-west-3"
# Resources will be prefixed with this to avoid clashing names
prefix = "cyri"
# Admin password to access Rancher
admin_password = "admin"
# Name of custom cluster that will be created
cluster_name = "cyri-demo"
# rancher/rancher image tag to use
rancher_version = "latest"
# Count of agent nodes with role all
count_agent_all_nodes = "1"
# Count of agent nodes with role etcd
count_agent_etcd_nodes = "0"
# Count of agent nodes with role controlplane
count_agent_controlplane_nodes = "0"
# Count of agent nodes with role worker
count_agent_worker_nodes = "0"
# Docker version of host running `rancher/rancher`
docker_version_server = "18.09"
# Docker version of host being added to a cluster (running `rancher/rancher-agent`)
docker_version_agent = "18.09"
# AWS Instance Type
type = "t2.medium"