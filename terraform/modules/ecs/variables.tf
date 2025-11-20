variable "task_definition_arn" {
    type = string
}

variable "public_subnets" {
    type = any
}

variable "security_group_id" {
    type = string
}

variable "target_group_arn" {
    type = string
}

variable "cluster_name" {
    type = string
}

variable "service_name" {
    type = string
}

variable "container_name" {
    type = string
}