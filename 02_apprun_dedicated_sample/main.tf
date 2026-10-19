terraform {
  required_providers {
    sakura = {
      source = "sacloud/sakura"

      # We recommend pinning to the specific version of the SakuraCloud Provider you're using
      # since new versions are released frequently
      version = "3.14.1"
      #version = "~> 3"
    }
  }
}

provider "sakura" {
  # More information on the authentication methods supported by
  # the SakuraCloud Provider can be found here:
  # https://docs.usacloud.jp/terraform/provider/

  # profile = ""
}

module "label" {
  source      = "cloudposse/label/null"
  namespace   = var.label["namespace"]
  name        = var.label["name"]
  attributes  = [var.label["namespace"], var.label["name"]]
  delimiter   = "-"
  label_order = ["namespace", "stage", "name"]
}
