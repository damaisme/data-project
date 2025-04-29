### Setup K8s on KVM 


#### Setup VM
1. Custom tf file to fit your environment

2. Apply terraform
```
terraform init
terraform apply
```

3. Wait for vm until pingable
```
ping 15.1.1.{11..13}
```

4. Access vm
```
ssh 15.1.1.11
```

#### Setup k8s 
1. Init cluster from node-1
```
kubeadm init --control-plane-endpoint "15.1.1.11:6443" --pod-network-cidr=10.244.0.0/16
```

2. Join as worker
```

```

3. Deploy flannel
```
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

```

4. Set master as worker to
```
kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane- --ignore-not-found
```
