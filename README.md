## About

This repo bootstraps a four node Kubernetes cluster on AWS using Terraform and kubeadm. Ideal for learning Kubernetes and Terraform, and a great plaything for simulating multi-host architecture. NOT suitable for production. Numerous security shortcuts were encoded to make setup and interaction with the cluster easier and faster. You have been warned!

### How it works

The terraform script builds out a new VPC in your account and 3 corresponding subnets. It will also provision an internet gateway and setup a routing table to allow internet access.

### Run it!

1. Clone the repo
- [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
- Generate token: `python -c 'import random; print "%0x.%0x" % (random.SystemRandom().getrandbits(3*8), random.SystemRandom().getrandbits(8*8))'`
- Generate ssh keys: `ssh-keygen -f k8s-test`
- Run terraform plan: `terraform plan -var k8s-ssh-key="$(cat k8s-test.pub)" -var 'k8stoken=<token>'`
- Build out infrastructure: `terraform apply -var k8s-ssh-key="$(cat k8s-test.pub)" -var 'k8stoken=<token>'`
- ssh to kube master and run something: `ssh ubuntu@$(terraform output master_dns) -i k8s-test`
- Done!

### Credit

I am not affiliated with UPMC but this project started as a fork of upmc-enterprises/kubeadm-aws! Most of the bootstrapping code was re-written since there was a bug that prevented the worker nodes from connecting to master on newer versions of k8s. I am also using Flannel as the network overlay. Nonetheless, major credit goes to stevesloka.