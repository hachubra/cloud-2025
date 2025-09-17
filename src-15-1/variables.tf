###cloud vars
variable "cloud_id" {
  type        = string
  default     = "b1g1li51c4ebgmu7e9s6"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gbldqcbvmq6hh0agh0"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "ig_zone" {
  type        = list(string)
  default     = ["ru-central1-a","ru-central1-b","ru-central1-d"]
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "nat_image_id" {
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
  description = "hardcode"
}

# variable "default_cidr" {
#   type        = list(string)
#   default     = ["10.0.1.0/24"]
#   description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
# }

variable "public_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "private_cidr" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

# variable "vpc_name" {
#   type        = string
#   default     = "develop"
#   description = "VPC network & subnet name"
# }

variable "vpc_name" {
  type        = string
  default     = "my_vpc"
  description = "VPC network & subnet name"
}

variable "vpc_name_public" {
  type        = string
  default     = "my_public"
  description = "VPC network & subnet name"
}

variable "vpc_name_private" {
  type        = string
  default     = "my_private"
  description = "VPC network & subnet name"
}

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Yandex compute image family"
}

# variable "vm_web_name" {
#   type        = string
#   default     = "netology-develop-platform-web"
#   description = "Yandex compute VM name"
# }

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v2"
  description = "Yandex compute VM platform id"
}

variable "route_table_name" {
  type        = string
  default      = "nat-instance-route"
  description = "Route Table Name"
}


variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "Yandex compute VM preemptible"
}

variable "vm_web_nat" {
  type        = bool
  default     = true
  description = "Yandex compute VM nat"
}

# variable "instance_name" {
#   type        = string
#   default     = "platform"
#   description = "Yandex compute instance name"
# }



variable "vms_resources" {
    type = map (object({
        cores  = number
        memory = number
        core_fraction = number
        boot_disk_type  = string
        boot_disk_size  = number
    }))
    default = {
        web={
            cores=2
            memory=2
            core_fraction=5
            boot_disk_type="network-ssd"
            boot_disk_size=10 
        }
    }    
}

locals {
  key = file("~/.ssh/new_key_kuber.pub")
}

variable "metadata" {
    type = map (object({
        serial_port = number
    }))
    default = {
        all={
            serial_port=1
        }
    }    
}

