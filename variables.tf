variable "region" {
    default = "eu-west-2"
    description = "AWS region to deploy"
}

variable "resource_name" {
    description = "Resource Name"
    type        = string
    default     = "mytf"
}