output "apr_info" {
  value = {
    "apr_appurl" = format("http://%s.sslip.io",sakura_internet.rtsw.ip_addresses[4])
    "apr_lb_global_ip" = sakura_internet.rtsw.ip_addresses[4]
  }
}