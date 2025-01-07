variable "cidr_block" {
  default = "10"
}
variable "Name" {
  default = "vProfile-opentofu-project"
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
  default     = "vProfile-opentofu"
}
