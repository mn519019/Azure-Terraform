# Number of vms
variable "vm_count" {
    default = "2" 
}

variable "env" { 
    default = "lab"
}

variable "ubuntu_version" {
    default = "18.04-LTS"
}

variable "admin_user"{
    default = "adminuser"
}

variable "port_protocol"{
    default = "22"
}

variable "security_group_protocol" {
    default = "SSH"
}

variable "resource_group_location" {
    default = "Canada Central"
}