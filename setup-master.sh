#!/bin/bash

# Kubernetes Master Setup

LOG=/tmp/kube-master.log 
rm -f $LOG

## Source Common Functions
curl -s "https://raw.githubusercontent.com/linuxautomations/scripts/master/common-functions.sh" >/tmp/common-functions.sh
source /tmp/common-functions.sh

#curl -s https://raw.githubusercontent.com/linuxautomations/docker/master/install-ce.sh | bash 
yum install docker -y 
systemctl enable docker
systemctl start docker 

echo '[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg' >/etc/yum.repos.d/kubernetes.repo

yum install -y kubelet kubeadm kubectl &>>$LOG
Stat $? "Installing Kubelet Service"

systemctl enable kubelet  &>/dev/null

systemctl start kubelet &>>$LOG 
Stat $? "Starting Kubelet Service"

exit

echo 'net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1' > /etc/sysctl.d/k8s.conf
sysctl --system &>> $LOG
Stat $? "Updating Network Configuration" 

sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload &>/dev/null
systemctl restart kubelet &>>$LOG 
Stat $? "Retarting Kubelet Service"