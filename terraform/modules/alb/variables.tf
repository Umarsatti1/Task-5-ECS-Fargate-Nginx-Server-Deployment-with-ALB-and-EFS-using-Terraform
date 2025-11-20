variable "vpc_id" {
    type = string 
}

variable "public_subnets" {
    type = any
}

variable "alb_security_group_id" {
    type = string 
}

variable "target_group_port" {
    type = number
}

variable "alb_name" {
    type = string
}

variable "lb_type" {
    type = string
}