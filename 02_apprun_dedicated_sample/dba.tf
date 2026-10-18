resource "sakura_database" "dba" {
  name = format("%s-%s", module.label.id, "db")
  zone = var.zone
  tags = ["${var.label["usecase"]}", "${var.label["deletiondate"]}", "${var.label["namespace"]}"]

  database_type    = "mariadb"
  database_version = "10.11" // optional
  plan             = "10g"

  username            = var.dba["user"]
  password_wo         = var.dba["password"]
  password_wo_version = 1
  network_interface = {
    vswitch_id = sakura_vswitch.sw.id
    ip_address = var.dba["ip"]
    netmask    = var.dba["netmask"]
    gateway    = var.dba["gateway"]
    port       = 3306
  }

  parameters = {
    max_connections = 100
  }
}