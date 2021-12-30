resource "azurerm_container_group" "aci_caddy" {
  resource_group_name = local.resource_group
  location            = local.location
  name                = local.container_group
  os_type             = "Linux"
  dns_name_label      = local.dns_name
  ip_address_type     = "public"
  
 /* 
  container {
    name    = "ql"
    image   = "whyour/qinglong:latest"
    cpu     = "0.5"
    memory  = "0.5"
  }
  */
  container {
    name   = "app"
    image  = "v2fly/v2fly-core:latest"
    cpu    = "0.5"
    memory = "0.5"

    commands = [
      "/bin/sh",
      "-c",
      "echo '${local.v2ray_config}' > /etc/v2ray/config.json; /usr/bin/v2ray -config /etc/v2ray/config.json"
    ]
  }

  container {
    name   = "caddy"
    image  = "caddy:latest"
    cpu    = "0.5"
    memory = "0.5"

    environment_variables = {
      SITE_ADDRESS = "${local.fqdn}"
    }

    ports {
      port     = 443
      protocol = "TCP"
    }

    ports {
      port     = 80
      protocol = "TCP"
    }

    volume {
      name                 = local.storage_share
      mount_path           = "/data"
      storage_account_name = azurerm_storage_account.aci_caddy.name
      storage_account_key  = azurerm_storage_account.aci_caddy.primary_access_key
      share_name           = azurerm_storage_share.aci_caddy.name
    }

    //commands = ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
    commands = [
        "/bin/sh",
        "-c",
        "echo \"${local.caddy_caddyfile}\" > /etc/caddy/Caddyfile; caddy run --config /etc/caddy/Caddyfile --adapter caddyfile"
        ]
  }
}

output "url" {
  value = "https://${azurerm_container_group.aci_caddy.fqdn}"
  description = "URL"
}
