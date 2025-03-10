resource "sakuracloud_server" "zbx_sv" {
  count = var.zbx_sv["count"]
  zone  = var.zone
  name  = format("%s-%s%02d", module.label.id, var.zbx_sv["name"], "${count.index + 1}")
  core  = var.zbx_sv["core"]
  memory  = var.zbx_sv["memory"]
  disks = [sakuracloud_disk.os_disk[count.index].id]
  
  dynamic "network_interface" {
    for_each = var.sw_already_exisits == false ? [1] : [] 
    content {
      upstream        = sakuracloud_switch.new_sw[0].id
      user_ip_address = cidrhost(var.new_sw["nw"],var.zbx_sv["start_ip"] + count.index)
    }
  }

  dynamic "network_interface" {
    for_each = var.sw_already_exisits == true ? [1] : [] 
    content {
      upstream        = data.sakuracloud_switch.existing_sw[0].id
      user_ip_address = cidrhost(var.existing_sw["nw"],var.zbx_sv["start_ip"] + count.index)
    }
  }

  user_data = data.template_file.user_data[count.index].rendered

  depends_on = [sakuracloud_ssh_key_gen.keys]
}

data "template_file" "user_data" {
  count = var.zbx_sv["count"]
  template = file("userdata/alma9_zabbix.yaml")
  vars = {
    hostname         = format("%s-%s%02d", module.label.id, var.zbx_sv["name"], count.index + 1)
    password         = var.password
    ssh_pubkey       = [sakuracloud_ssh_key_gen.keys[count.index].public_key]
    ip_address       = var.sw_already_exisits == true ? cidrhost(var.existing_sw["nw"], var.zbx_sv["start_ip"] + count.index) : cidrhost(var.new_sw["nw"],var.zbx_sv["start_ip"] + count.index)
    gateway      = var.sw_already_exisits == true ? var.existing_sw["gw"] : sakuracloud_vpc_router.vpcrt[0].private_network_interface[0].ip_addresses[0]
    netmask         = var.sw_already_exisits == true ? var.existing_sw["netmask"] : sakuracloud_vpc_router.vpcrt[0].private_network_interface[0].netmask
    ssh_pubkey       = sakuracloud_ssh_key_gen.keys[count.index].public_key
  }
}


data "sakuracloud_archive" "os" {
  zone = var.zone
  filter {
    tags = ["distro-alma", "centos-alternative-9" , "cloud-init"]
  }
}
resource "sakuracloud_disk" "os_disk" {
  count = var.zbx_sv["count"]
  name              = format("%s-%s%02d%s", module.label.id, var.zbx_sv["name"], "${count.index + 1}","os_disk")
  zone              = var.zone
  source_archive_id = data.sakuracloud_archive.os.id
}
