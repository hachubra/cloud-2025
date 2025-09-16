resource "yandex_compute_instance" "web" {
    depends_on = [yandex_compute_instance.db]
    count = 1
    name = "nat-${count.index+1}"
    platform_id = var.vm_web_platform_id #not standart-v4
    zone        = var.default_zone
  resources { 
    cores         = var.vms_resources.web.cores #1 not allow
    memory        = var.vms_resources.web.memory
    core_fraction = var.vms_resources.web.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      type  = var.vms_resources.web.boot_disk_type
      size  = var.vms_resources.web.boot_disk_size
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = var.vm_web_nat
    security_group_ids = [yandex_vpc_security_group.example.id]
    ip_address = "192.168.10.254"
  }
    metadata = {
    serial-port-enable = var.metadata.all.serial_port
    ssh-keys           = "ubuntu:${local.key}"
  }
}


resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = var.route_table_name
  network_id = yandex_vpc_network.my_vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}


data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}

#   metadata = {
#     serial-port-enable = var.metadata.all.serial_port
#     ssh-keys           = var.metadata.all.ssh_key
#   }

