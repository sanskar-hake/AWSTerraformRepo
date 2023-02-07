variable "image" {
  type = string
  default = "ami-0c7cb70d3eb61492b"
}

variable "pwd" {
  type = string
  default = "admin"
}

variable "instance_count" {
  default = "3"
}

variable "instance_names" {
    type = list
    default = ["Master Cloud","Edge Cloud 1","Edge Cloud 2"]
}

variable "instance_types" {
    type = list
    default = ["t2.medium","t2.micro","t2.large"]
}

variable "securitygrouprule_count" {
  default = "8"
}

variable "from_port" {
  type = list
  default = [8080,10000,2379,10002,6443,22,30000,10249]
}

variable "to_port" {
  type = list
  default = [8080,10000,2380,10002,6443,22,32767,10253]
}

variable "command1" {
    type = list
    default = ["sudo bash /root/KubeEdge-demo/kubeedge-cloud-install/cloud-core-install.sh","sudo bash /root/KubeEdge-demo/kubeedge-edge-install/edge-core-install.sh","sudo bash /root/KubeEdge-demo/kubeedge-edge-install/edge-core-install.sh"]
    # default = ["bash /root/KubeEdge-demo/kubeedge-cloud-install/cloud-core-install.sh","bash /root/KubeEdge-demo/kubeedge-edge-install/edge-core-install.sh","bash /root/KubeEdge-demo/kubeedge-edge-install/edge-core-install.sh"]
}

variable "command2" {
    type = list
    default = ["sudo bash /root/KubeEdge-demo/kubeedge-cloud-install/obtain-token.sh","",""]
}