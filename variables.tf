variable "cidr_block" {
  default = "10"
}
variable "Name" {
  default = "vProfile-opentofu-project"
}

variable "cluster_role" {
  type = map(any)
  default = {
    role_name = "cluster_role"
    service   = "eks"
  }
}
variable "ec2_role" {
  default = ["node_role", "access_role"]
}
variable "cluster_name" {
  default = "eks_cluster"
}

variable "cluster_compute" {
  type = map(any)
  default = {
    instance_types = "t3.micro"
    desired_size   = 2
    max_size       = 3
    min_size       = 1
    ec2_ssh_key    = "dummy"
  }
}

variable "instance_types" {
  description = "The type of instance to start"
  type        = map(string)
  default = {
    "nano"    = "t3.nano"
    "micro"   = "t3.micro"
    "small"   = "t3.small"
    "medium"  = "t3.medium"
    "large"   = "t3.large"
    "xlarge"  = "t3.xlarge"
    "2xlarge" = "t3.2xlarge"
  }
}

variable "keyname" {
  description = "The name of the key pair to use"
  type        = string
  default     = "opentofu"
}