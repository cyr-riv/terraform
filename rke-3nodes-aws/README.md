 # Offer a service to provision a Kubernetes cluster on AWS.
 ## Demo steps
1. Create a k8s cluster with 1 master and 2 workers with [RKE plugin](https://github.com/yamamoto-febc/terraform-provider-rke).
2. Deploy an application (nginx) on both workers.
3. Upgrade the k8s cluster to v1.15 for all nodes.