resource "sakuracloud_ssh_key_gen" "keys" {
  count = var.zbx_sv["count"]
  name       = "sshkey_zbx0${count.index+1}"
}

resource "local_file" "ssh_keys" {
  count = var.zbx_sv["count"]
  content  = sakuracloud_ssh_key_gen.keys[0].private_key
  filename = "./id_rsa_zbx0${count.index+1}"
  file_permission = "0400"
}