data "sakuracloud_switch" "existing_sw" {
  count  = var.sw_already_exisits == true ? 1 : 0
  zone = var.zone
  filter {
    id = var.existing_sw["sw_id"]
  }
}

resource "sakuracloud_switch" "new_sw" {
  count  = var.sw_already_exisits == true ? 0 : 1
  name = format("%s-%s", module.label.id, "sw")
  zone = var.zone
}