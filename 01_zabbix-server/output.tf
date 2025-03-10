output "server_info" {
  value = {
    "hostname"        = data.template_file.user_data[*].vars.hostname,
    "os"              = data.sakuracloud_archive.os.name,
    "ip_address"      = sakuracloud_server.zbx_sv[*].network_interface[0].user_ip_address,
    "ssh_cmd_example_pub" = try(format("ssh sacloud-user@%s -p %s -i id_rsa_zbx01", sakuracloud_vpc_router.vpcrt[0].public_ip, var.vpcrt["pf_ssh_pub"]), ""),
    "ssh_cmd_example_prv" = format("ssh sacloud-user@%s -i id_rsa_zbx01", sakuracloud_server.zbx_sv[0].ip_address)
  }
}

output "vpcrt_info" {
  value = {
    "vpcrt_ip"         = sakuracloud_vpc_router.vpcrt[*].public_ip,
  }
}

output "zabbix_url" {
  value = {
    "zabbix_url_pub" = try(format("http://%s:%s", sakuracloud_vpc_router.vpcrt[0].public_ip, var.vpcrt["pf_zabbix_pub"]), ""),
    "zabbix_url_prv" = format("http://%s:8080", sakuracloud_server.zbx_sv[0].network_interface[0].user_ip_address)
  }
}