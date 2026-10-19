variable "zone" {
  default = "is1c" # tk1b, is1b, is1c # tk1a, is1a
}

variable "label" {
  default = {
    namespace    = "name"
    name         = "dev"
    usecase      = "@Normal"
    deletiondate = "Del20261026"
  }
}

variable "password" {
  nullable = false
}

variable "seg" {
  default = {
    ip_address          = "192.168.0.1"
    netmask             = "24"
    cr_fqdn             = "app-sakura-handson.sakuracr.jp"
    cr_fqdn_version_tag = "app-sakura-handson.sakuracr.jp/php-board:1.0"
    cr_user             = "handson-user"
    cr_pass             = "handson-sakura"
  }
}

variable "dba" {
  default = {
    user     = "app_user"
    password = "handson-sakura"
    ip       = "192.168.0.10"
    netmask  = 24
    gateway  = "192.168.0.1"
  }
}

variable "secret_db_pass" {}

variable "apr" {
  default = {
    cluster_port                = "80"
    cluster_protocol            = "http"
    worker_service_class_path   = "cloud/apprun/dedicated/worker/1vcpu_2gb"
    lb_service_class_path       = "cloud/apprun/dedicated/lb/1vcpu_2gb_1"
    sp_id                       = ""
    wk_min_nodes                = "1"
    wk_max_nodes                = "2"
    wk_prv1_ip_s                = "192.168.0.20"
    wk_prv1_ip_e                = "192.168.0.30"
    wk_prv1_netmask             = "24"
    lb_prv1_ip_s                = "192.168.0.40"
    lb_prv1_ip_e                = "192.168.0.50"
    lb_prv1_netmask             = "24"
    version_cpu                 = "100"
    version_memory              = "256"
    version_max_scale           = "2"
    version_min_scale           = "1"
    version_scale_in_threshold  = "30"
    version_scale_out_threshold = "90"
    version_target_port         = "8080"
    version_hc_interval_seconds = "30"
    version_hc_path             = "/healthz.php"
    version_hc_timeout_seconds  = "30"

  }
}

variable "apr_env_map" {
  type = map(string)
  default = {
    DB_HOST = "192.168.0.10"
    PORT    = "3306"
    DB_NAME = "app_user"
    DB_USER = "app_user"
  }
}
