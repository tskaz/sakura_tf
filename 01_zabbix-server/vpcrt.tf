resource "sakuracloud_vpc_router" "vpcrt" {
  count  = var.sw_already_exisits == true ? 0 : 1
  name                = format("%s-%s", module.label.id, "vpcrt")
  plan                = var.vpcrt["plan"]
  internet_connection = true
  zone                = var.zone

  private_network_interface {
    index        = 1
    switch_id    = sakuracloud_switch.new_sw[0].id
    ip_addresses   = [cidrhost(var.vpcrt["prv_nw"],var.vpcrt["prv_hostip"])]
    netmask      = var.vpcrt["netmask"]
  }
  port_forwarding {
    protocol     = "tcp"
    public_port  = var.vpcrt["pf_zabbix_pub"]
    private_ip   = var.sw_already_exisits == true ? cidrhost(var.existing_sw["nw"], var.zbx_sv["start_ip"] + count.index) : cidrhost(var.new_sw["nw"],var.zbx_sv["start_ip"] + count.index)
    private_port =  var.vpcrt["pf_zabbix_prv"]
    description  = "zabbix-web"
  }
  port_forwarding {
    protocol     = "tcp"
    public_port  = var.vpcrt["pf_ssh_pub"]
    private_ip   = var.sw_already_exisits == true ? cidrhost(var.existing_sw["nw"], var.zbx_sv["start_ip"] + count.index) : cidrhost(var.new_sw["nw"],var.zbx_sv["start_ip"] + count.index)
    private_port =  var.vpcrt["pf_ssh_prv"]
    description  = "ssh"
  }
}
