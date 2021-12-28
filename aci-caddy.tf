terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location = "East Asia"
  dns_name = "acicaddy-wall"
  resource_group = "acicaddy_rg"
  storage_account = "acicaddysa"
  storage_share = "acicaddy-share"
  container_group = "acicaddy_cg"
  fqdn = "${local.dns_name}.${data.azurerm_resource_group.aci_caddy_data.location}.azurecontainer.io"
}

variable "createuuid" {
  type = bool
  default = true
}

locals {
  caddy_caddyfile = file("Caddyfile")
  
  v2ray_id = var.createuuid == true ? uuid() : "c81c95d8-922a-b090-54be-ab47b6cb1830"
  v2ray_config = replace(file("config.json"), "/\"id\": \".*\",/", "\"id\": \"${local.v2ray_id}\",")
  v2ray_tmp = replace(file("client.json"), "/\"id\": \".*\",/", "\"id\": \"${local.v2ray_id}\",")
  v2ray_client = replace(local.v2ray_tmp, "/\"address\": \".*\",/", "\"address\": \"${local.fqdn}\",")
}

resource "local_file" "v2ray_config" {
    content         = local.v2ray_config
    filename        = "config.json"
    file_permission = "0644"
}

resource "local_file" "v2ray_client" {
    content         = local.v2ray_client
    filename        = "client.json"
    file_permission = "0644"
}

