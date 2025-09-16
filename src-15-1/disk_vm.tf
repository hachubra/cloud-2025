# resource yandex_compute_disk "additional_disks"{
#     count = 3
#     name     = "disk-${count.index+1}"
#     type     = "network-ssd"
#     size     = 1
#     zone     = var.default_zone
# }

# resource "yandex_compute_instance" "storage" {
#     depends_on = [yandex_compute_instance.db,yandex_compute_disk.additional_disks ]
#     name = "storage"
#     platform_id = var.vm_web_platform_id #not standart-v4
#     zone        = var.default_zone
#   resources { 
#     cores         = var.vms_resources.web.cores #1 not allow
#     memory        = var.vms_resources.web.memory
#     core_fraction = var.vms_resources.web.core_fraction
#   }
#   boot_disk {
#     initialize_params {
#       image_id = data.yandex_compute_image.ubuntu.image_id
#       type  = var.vms_resources.web.boot_disk_type
#       size  = var.vms_resources.web.boot_disk_size
#     }
#   }



#   dynamic "secondary_disk"{
#     for_each = yandex_compute_disk.additional_disks
#     content {
#       disk_id     = yandex_compute_disk.additional_disks[secondary_disk.key].id
    
#     }
#   }




#   scheduling_policy {
#     preemptible = var.vm_web_preemptible
#   }
#   network_interface {
#     subnet_id = yandex_vpc_subnet.develop.id
#     nat       = var.vm_web_nat
#     security_group_ids = [yandex_vpc_security_group.example.id]
#   }
#     metadata = {
#     serial-port-enable = var.metadata.all.serial_port
#     ssh-keys           = "ubuntu:${local.key}"
#   }
# }
