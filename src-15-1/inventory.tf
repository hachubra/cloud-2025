resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl",

  { webservers = yandex_compute_instance.web, 
    databases = yandex_compute_instance.db, 
    private = yandex_compute_instance.db2, 
    # storage = [yandex_compute_instance.storage] 
    })

  filename = "${abspath(path.module)}/hosts.ini"
}

resource "local_file" "hosts_for" {
  content =  <<-EOT
  %{if length(yandex_compute_instance.web) > 0}
  [webservers]
  %{for i in yandex_compute_instance.web }
  ${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"] }
  %{endfor}
  %{endif}


  %{if length(yandex_compute_instance.db) > 0}
  [databases]
  %{for i in yandex_compute_instance.db }
  ${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"] }
  %{endfor}
  %{endif}

 %{if length(yandex_compute_instance.db2) > 0}
  [private]
  %{for i in yandex_compute_instance.db2 }
  ${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"] }
  %{endfor}
  %{endif}


  EOT
  filename = "${abspath(path.module)}/for.ini"
}



# locals{

# instances_yaml= concat(yandex_compute_instance.web,yandex_compute_instance.db,[yandex_compute_instance.storage])

# }

# resource "local_file" "hosts_yaml" {
#   content =  <<-EOT
#   all:
#     hosts:
#     %{ for i in local.instances_yaml ~}
#   ${i["name"]}:
#           ansible_host: ${i["network_interface"][0]["nat_ip_address"]}
#           ansible_user: ubuntu
#     %{ endfor ~}
#   EOT
#   filename = "${abspath(path.module)}/hosts.yaml"
# }
