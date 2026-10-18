resource "sakura_apprun_dedicated_cluster" "main" {
  name                 = format("%s-%s", module.label.id, "ar")
  service_principal_id = var.apr["sp_id"]
  ports = [
    {
      port     = var.apr["cluster_port"]
      protocol = var.apr["cluster_protocol"]
    }
  ]
}

locals {
  sakura_dns = ["133.242.0.3", "133.242.0.4"]
}

# data "sakura_apprun_dedicated_worker_service_classes" "main" {}

resource "sakura_apprun_dedicated_auto_scaling_group" "asg" {
  cluster_id                = sakura_apprun_dedicated_cluster.main.id
  name                      = format("%s-%s", module.label.id, "asg")
  zone                      = var.zone
  worker_service_class_path = var.apr["worker_service_class_path"]
  # worker_service_class_path = data.sakura_apprun_dedicated_worker_service_classes.main.classes[0].path
  name_servers = ["${var.seg["ip_address"]}"]
  #  name_servers              = local.sakura_dns
  min_nodes = var.apr["wk_min_nodes"]
  max_nodes = var.apr["wk_max_nodes"]

  interfaces = [
    {
      interface_index = 0
      upstream        = sakura_vswitch.sw.id
      connects_to_lb  = true
      netmask         = "${var.apr["wk_prv1_netmask"]}"
      default_gateway = "${var.seg["ip_address"]}"
      ip_pool = [{
        start = "${var.apr["wk_prv1_ip_s"]}"
        end   = "${var.apr["wk_prv1_ip_e"]}"
      }]
    }
  ]
}

resource "sakura_apprun_dedicated_application" "app" {
  cluster_id = sakura_apprun_dedicated_cluster.main.id
  name       = format("%s-%s", module.label.id, "app")
}

resource "sakura_apprun_dedicated_version" "version" {
  application_id           = sakura_apprun_dedicated_application.app.id
  cpu                      = var.apr["version_cpu"]
  memory                   = var.apr["version_memory"]
  image                    = var.seg["cr_fqdn_version_tag"]
  registry_password        = var.seg["cr_pass"]
  registry_username        = var.seg["cr_user"]
  registry_password_action = "new"
  scaling_mode             = "cpu"
  max_scale                = var.apr["version_max_scale"]
  min_scale                = var.apr["version_min_scale"]
  scale_in_threshold       = var.apr["version_scale_in_threshold"]
  scale_out_threshold      = var.apr["version_scale_out_threshold"]
  exposed_ports = [{
    target_port = var.apr["version_target_port"]
    health_check = {
      interval_seconds = var.apr["version_hc_interval_seconds"]
      path             = var.apr["version_hc_path"]
      timeout_seconds  = var.apr["version_hc_timeout_seconds"]
    }
    lb_port = var.apr["cluster_port"]
    host    = ["${sakura_internet.rtsw.ip_addresses[4]}.sslip.io","${sakura_internet.rtsw.ip_addresses[4]}"]
  }]
  env_vars = [
    for k, v in
    merge(
      var.apr_env_map,
      {
        # If want to add env, write here.
      }
      ) : {
      key    = k
      value  = v
    }
  ]
  secret_vars = [
    {
      key              = "DB_PASS"
      value_wo         = var.secret_db_pass # write-only: never stored in the state
      value_wo_version = 1                  # bump this to create a new version with a new value_wo
    },
  ]
}

resource "sakura_apprun_dedicated_lb" "lb" {
  cluster_id            = sakura_apprun_dedicated_cluster.main.id
  auto_scaling_group_id = sakura_apprun_dedicated_auto_scaling_group.asg.id
  name                  = format("%s-%s", module.label.id, "lb")
  service_class_path    = var.apr["lb_service_class_path"]
  name_servers          = local.sakura_dns

  interfaces = [
    {
    interface_index = 0
    upstream        = sakura_internet.rtsw.vswitch_id
    default_gateway = sakura_internet.rtsw.gateway
    netmask         = 24
    ip_pool = [{
      start = sakura_internet.rtsw.ip_addresses[4]
      end   = sakura_internet.rtsw.ip_addresses[5]
    }]
    },
    {
      interface_index = 1
      upstream        = sakura_vswitch.sw.id
      connects_to_lb  = false
      netmask         = "${var.apr["lb_prv1_netmask"]}"
      ip_pool = [{
        start = "${var.apr["lb_prv1_ip_s"]}"
        end   = "${var.apr["lb_prv1_ip_e"]}"
      }]
    }
  ]
}
