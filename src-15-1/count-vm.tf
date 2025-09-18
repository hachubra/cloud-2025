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


# Создание бакета с использованием IAM-токена


resource "yandex_kms_symmetric_key" "key-solovev" {
  name              = "key-s"
  description       = "homework-15.3-cloud"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // 1 год
}

resource "yandex_storage_bucket" "solovev_bucket" {
  bucket    = "mybucketsolovev1"
  folder_id = var.folder_id
  max_size   = 10485760
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-solovev.id
        sse_algorithm     = "aws:kms"
      }
    }
  }  
}

resource "yandex_storage_object" "image_object" {
  # access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  # secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "mybucketsolovev1"
  key        = "my_image.png"
  source     = "/home/alex/cloud-2025/img/1.png"
}





data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}

#   metadata = {
#     serial-port-enable = var.metadata.all.serial_port
#     ssh-keys           = var.metadata.all.ssh_key
#   }

resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "Сервисный аккаунт для управления группой ВМ."
}

resource "yandex_resourcemanager_folder_iam_member" "compute-editor" {
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
}

# resource "yandex_resourcemanager_folder_iam_member" "load-balancer-editor" {
#   folder_id = var.folder_id
#   role      = "load-balancer.editor"
#   member    = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
# }

resource "yandex_compute_instance_group" "ig-1" {
  name                = "fixed-ig-with-balancer"
  folder_id           = var.folder_id
  service_account_id  = "${yandex_iam_service_account.ig-sa.id}"
  deletion_protection = false
  instance_template {
    platform_id = var.vm_web_platform_id 
    resources {
      cores         = var.vms_resources.web.cores #1 not allow
      memory        = var.vms_resources.web.memory
      core_fraction = var.vms_resources.web.core_fraction
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }
    scheduling_policy {
    preemptible = var.vm_web_preemptible
    }
    
  network_interface {
    network_id = "${yandex_vpc_network.my_vpc.id}"
    subnet_ids = [yandex_vpc_subnet.public.id]
    nat       = var.vm_web_nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

    metadata = {
    serial-port-enable = var.metadata.all.serial_port
    ssh-keys           = "ubuntu:${local.key}"
    user-data = "${file("cloud-init.yaml")}"
    # "runcmd: 'echo https://storage.yandexcloud.net/mybucketsolovev1/my_image.png > /var/www/html/index.html'"
  }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "Целевая группа Network Load Balancer"
  }
}

resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "network-load-balancer-1"

  listener {
    name = "network-load-balancer-1-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-1.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}
