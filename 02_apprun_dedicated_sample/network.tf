resource "sakura_vswitch" "sw" {
  name = format("%s_%s", module.label.id, "sw")
  tags = ["${var.label["usecase"]}", "${var.label["deletiondate"]}", "@${var.label["namespace"]}"]
  zone = var.zone
}

resource "sakura_seg" "seg" {
  vswitch_id          = sakura_vswitch.sw.id
  zone                = var.zone
  server_ip_addresses = ["${var.seg["ip_address"]}"] # e,g. 192.168.1.1 
  netmask             = var.seg["netmask"]           # 8-29
  timeouts = {
    create = "5m"
    delete = "5m"
  }
  endpoint_setting = {
    container_registry_endpoints = ["${var.seg["cr_fqdn"]}"] # e.g. *****.sakuracr.jp
    #        monitoring_suite_endpoints = [sakura_monitoring_suite_log_storage.log.endpoints.ingester.address]
    apprun_dedicated_control_enabled = true
  }
}

resource "sakura_internet" "rtsw" {
  name        = format("%s_%s", module.label.id, "rtsw")
  zone        = var.zone
  netmask     = 28
  band_width  = 100
  enable_ipv6 = false
  tags        = ["${var.label["usecase"]}", "${var.label["deletiondate"]}", "@${var.label["namespace"]}"]
}