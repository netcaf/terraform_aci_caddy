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

locals {
  caddy_caddyfile = file("Caddyfile")
  
  v2ray_config = file("config.json")
  v2ray_client = file("client.json")
}

