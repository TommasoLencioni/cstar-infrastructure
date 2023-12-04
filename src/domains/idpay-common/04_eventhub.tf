locals {
  jaas_config_template_idpay = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$ConnectionString\" password=\"%s\";"
}

resource "azurerm_resource_group" "msg_rg" {
  name     = "${local.product}-${var.domain}-msg-rg"
  location = var.location

  tags = var.tags
}

#module "event_hub_idpay_00" {
#
#  count = var.enable.idpay.eventhub_idpay_00 ? 1 : 0
#
#  source                   = "git::https://github.com/pagopa/terraform-azurerm-v3.git//eventhub?ref=v6.15.2"
#  name                     = "${local.product}-${var.domain}-evh-ns-00"
#  location                 = var.location
#  resource_group_name      = azurerm_resource_group.msg_rg.name
#  auto_inflate_enabled     = var.eventhub_idpay_namespace.auto_inflate_enabled
#  sku                      = var.eventhub_idpay_namespace.sku
#  capacity                 = var.eventhub_idpay_namespace.capacity
#  maximum_throughput_units = var.eventhub_idpay_namespace.maximum_throughput_units
#  zone_redundant           = var.eventhub_idpay_namespace.zone_redundant
#  minimum_tls_version      = var.eventhub_idpay_namespace.minimum_tls_version
#
#  virtual_network_ids = [
#    data.azurerm_virtual_network.vnet_integration.id,
#    data.azurerm_virtual_network.vnet_core.id
#  ]
#  subnet_id = data.azurerm_subnet.eventhub_snet.id
#
#  eventhubs = var.eventhubs_idpay_00
#
#  private_dns_zones = {
#    id   = [data.azurerm_private_dns_zone.ehub.id]
#    name = [data.azurerm_private_dns_zone.ehub.name]
#  }
#  private_dns_zone_record_A_name  = "eventhubidpay00"
#  private_dns_zone_resource_group = data.azurerm_private_dns_zone.ehub.resource_group_name
#
#  alerts_enabled = var.ehns_alerts_enabled
#  metric_alerts  = var.ehns_metric_alerts
#  action = [
#    {
#      action_group_id    = local.monitor_action_group_email_name
#      webhook_properties = null
#    },
#    {
#      action_group_id    = local.monitor_action_group_email_name
#      webhook_properties = null
#    }
#  ]
#
#  network_rulesets = [
#    {
#      default_action                 = "Deny"
#      trusted_service_access_enabled = true
#      virtual_network_rule = [
#        {
#          subnet_id                                       = data.azurerm_subnet.eventhub_snet.id
#          ignore_missing_virtual_network_service_endpoint = false
#        },
#        {
#          subnet_id                                       = data.azurerm_subnet.aks_domain_subnet.id
#          ignore_missing_virtual_network_service_endpoint = false
#        },
#        {
#          subnet_id                                       = data.azurerm_subnet.private_endpoint_snet.id
#          ignore_missing_virtual_network_service_endpoint = false
#        }
#      ]
#      ip_rule = []
#    }
#  ]
#
#  # fixme. defined for backward compatibility, needs to be changed to false
#  public_network_access_enabled = true
#
#
#  tags = var.tags
#}

resource "azurerm_private_endpoint" "event_hub_idpay_00_private_endpoint" {
  # disabled in PROD
  count               = var.enable.idpay.eventhub_idpay_00 && var.env_short != "p" ? 1 : 0
  name                = "${local.project}-evh-00-private-endpoint"
  location            = var.location
  resource_group_name = local.vnet_core_resource_group_name
  subnet_id           = data.azurerm_subnet.private_endpoint_snet.id

  private_dns_zone_group {
    name = data.azurerm_private_dns_zone.ehub.name
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.ehub.id
    ]
  }

  private_service_connection {
    name                           = "${local.project}-evh-00-private-service-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_eventhub_namespace.event_hub_idpay_namespace_00[0].id
    subresource_names              = ["namespace"]
  }
}

##tfsec:ignore:AZU023
#resource "azurerm_key_vault_secret" "event_hub_keys_idpay_00" {
#  for_each = module.event_hub_idpay_00[0].key_ids
#
#  name         = format("evh-%s-%s-idpay-00", replace(each.key, ".", "-"), "jaas-config")
#  value        = format(local.jaas_config_template_idpay, module.event_hub_idpay_00[0].keys[each.key].primary_connection_string)
#  content_type = "text/plain"
#
#  key_vault_id = module.key_vault_idpay.id
#}

resource "azurerm_eventhub_namespace" "event_hub_idpay_namespace_00" {
  count                    = var.enable.idpay.eventhub_idpay_00 ? 1 : 0
  name                     = "${local.product}-${var.domain}-evh-ns-00"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.msg_rg.name
  auto_inflate_enabled     = var.eventhub_idpay_namespace.auto_inflate_enabled
  sku                      = var.eventhub_idpay_namespace.sku
  capacity                 = var.eventhub_idpay_namespace.capacity
  maximum_throughput_units = var.eventhub_idpay_namespace.maximum_throughput_units
  zone_redundant           = var.eventhub_idpay_namespace.zone_redundant
  minimum_tls_version      = var.eventhub_idpay_namespace.minimum_tls_version

  network_rulesets {
    default_action = "Deny"
    # list of subnet where eventhub is reachable
    virtual_network_rule {
      subnet_id = data.azurerm_subnet.eventhub_snet.id
    }
    virtual_network_rule {
      subnet_id = data.azurerm_subnet.aks_domain_subnet.id
    }
    virtual_network_rule {
      subnet_id = data.azurerm_subnet.private_endpoint_snet.id
    }
    trusted_service_access_enabled = true
  }

  tags = var.tags
}
resource "azurerm_eventhub_namespace" "event_hub_idpay_namespace_01" {
  count                    = var.enable.idpay.eventhub_idpay_00 ? 1 : 0
  name                     = "${local.product}-${var.domain}-evh-ns-01"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.msg_rg.name
  auto_inflate_enabled     = var.eventhub_idpay_namespace.auto_inflate_enabled
  sku                      = var.eventhub_idpay_namespace.sku
  capacity                 = var.eventhub_idpay_namespace.capacity
  maximum_throughput_units = var.eventhub_idpay_namespace.maximum_throughput_units
  zone_redundant           = var.eventhub_idpay_namespace.zone_redundant
  minimum_tls_version      = var.eventhub_idpay_namespace.minimum_tls_version

  network_rulesets {
    default_action = "Deny"
    # list of subnet where eventhub is reachable
    virtual_network_rule {
      subnet_id = data.azurerm_subnet.eventhub_snet.id
    }
    virtual_network_rule {
      subnet_id = data.azurerm_subnet.aks_domain_subnet.id
    }
    virtual_network_rule {
      subnet_id = data.azurerm_subnet.private_endpoint_snet.id
    }
    trusted_service_access_enabled = true
  }

  tags = var.tags
}
#
# Eventhub queues for idpay namespace
#
resource "azurerm_eventhub" "event_hub_idpay_00_hubs" {
  for_each            = { for hub in var.eventhubs_idpay_00 : hub.name => hub }
  name                = each.value.name
  partition_count     = each.value.partitions
  message_retention   = each.value.message_retention
  namespace_name      = azurerm_eventhub_namespace.event_hub_idpay_namespace_00[0].name
  resource_group_name = azurerm_resource_group.msg_rg.name
  depends_on          = [azurerm_eventhub_namespace.event_hub_idpay_namespace_00[0]]
}

resource "azurerm_eventhub" "event_hub_idpay_01_hubs" {
  for_each            = { for hub in var.eventhubs_idpay_01 : hub.name => hub }
  name                = each.value.name
  partition_count     = each.value.partitions
  message_retention   = each.value.message_retention
  namespace_name      = azurerm_eventhub_namespace.event_hub_idpay_namespace_01[0].name
  resource_group_name = azurerm_resource_group.msg_rg.name
  depends_on          = [azurerm_eventhub_namespace.event_hub_idpay_namespace_01[0]]
}

#
# Eventhub consumer groups
#
resource "azurerm_eventhub_consumer_group" "event_hub_idpay_00_consumer_group" {
  for_each = merge([for hub in var.eventhubs_idpay_00 : { for consumer in hub.consumers : "${hub.name}-${consumer}" => { eventhub_name = hub.name, name = consumer } }]...)

  eventhub_name       = each.value.eventhub_name
  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_idpay_namespace_00[0].name
  resource_group_name = azurerm_resource_group.msg_rg.name
  depends_on          = [azurerm_eventhub_namespace.event_hub_idpay_namespace_00[0]]
}

resource "azurerm_eventhub_consumer_group" "event_hub_idpay_01_consumer_group" {
  for_each = merge([for hub in var.eventhubs_idpay_01 : { for consumer in hub.consumers : "${hub.name}-${consumer}" => { eventhub_name = hub.name, name = consumer } }]...)

  eventhub_name       = each.value.eventhub_name
  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.event_hub_idpay_namespace_01[0].name
  resource_group_name = azurerm_resource_group.msg_rg.name
  depends_on          = [azurerm_eventhub_namespace.event_hub_idpay_namespace_01[0]]
}

#
# Eventhub policies
#
resource "azurerm_eventhub_authorization_rule" "event_hub_idpay_00_policy" {
  for_each = merge([for hub in var.eventhubs_idpay_00 : { for policy in hub.policies : policy.name => { hub_name = hub.name, policy = policy } }]...)

  name                = each.value.policy.name
  eventhub_name       = each.value.hub_name
  namespace_name      = azurerm_eventhub_namespace.event_hub_idpay_namespace_00[0].name
  resource_group_name = azurerm_resource_group.msg_rg.name
  listen              = each.value.policy.listen
  send                = each.value.policy.send
  manage              = each.value.policy.manage
  depends_on          = [azurerm_eventhub_namespace.event_hub_idpay_namespace_00[0]]
}

resource "azurerm_eventhub_authorization_rule" "event_hub_idpay_01_policy" {
  for_each = merge([for hub in var.eventhubs_idpay_01 : { for policy in hub.policies : policy.name => { hub_name = hub.name, policy = policy } }]...)

  name                = each.value.policy.name
  eventhub_name       = each.value.hub_name
  namespace_name      = azurerm_eventhub_namespace.event_hub_idpay_namespace_01[0].name
  resource_group_name = azurerm_resource_group.msg_rg.name
  listen              = each.value.policy.listen
  send                = each.value.policy.send
  manage              = each.value.policy.manage
  depends_on          = [azurerm_eventhub_namespace.event_hub_idpay_namespace_01[0]]
}

resource "azurerm_key_vault_secret" "event_hub_keys_idpay_00" {
  for_each = merge([for hub in var.eventhubs_idpay_00 : { for policy in hub.policies : policy.name => { hub_name = hub.name, policy = policy } }]...)

  name = format("evh-%s-%s-idpay-00", replace(each.key, ".", "-"), "jaas-config")
  value = format(local.jaas_config_template_idpay, azurerm_eventhub_authorization_rule.event_hub_idpay_00_policy[each.key].primary_connection_string)
  content_type = "text/plain"

  key_vault_id = module.key_vault_idpay.id
}

#module "event_hub_idpay_01" {
#
#  count = var.enable.idpay.eventhub_idpay_00 ? 1 : 0
#
#  source                   = "git::https://github.com/pagopa/terraform-azurerm-v3.git//eventhub?ref=v6.15.2"
#  name                     = "${local.product}-${var.domain}-evh-ns-01"
#  location                 = var.location
#  resource_group_name      = azurerm_resource_group.msg_rg.name
#  auto_inflate_enabled     = var.eventhub_idpay_namespace.auto_inflate_enabled
#  sku                      = var.eventhub_idpay_namespace.sku
#  capacity                 = var.eventhub_idpay_namespace.capacity
#  maximum_throughput_units = var.eventhub_idpay_namespace.maximum_throughput_units
#  zone_redundant           = var.eventhub_idpay_namespace.zone_redundant
#  minimum_tls_version      = var.eventhub_idpay_namespace.minimum_tls_version
#
#  virtual_network_ids = [
#    data.azurerm_virtual_network.vnet_integration.id,
#    data.azurerm_virtual_network.vnet_core.id
#  ]
#  subnet_id = data.azurerm_subnet.eventhub_snet.id
#
#  eventhubs = var.eventhubs_idpay_01
#
#  private_dns_zones = {
#    id   = [data.azurerm_private_dns_zone.ehub.id]
#    name = [data.azurerm_private_dns_zone.ehub.name]
#  }
#  private_dns_zone_record_A_name  = "eventhubidpay01"
#  private_dns_zone_resource_group = data.azurerm_private_dns_zone.ehub.resource_group_name
#
#  alerts_enabled = var.ehns_alerts_enabled
#  metric_alerts  = var.ehns_metric_alerts
#  action = [
#    {
#      action_group_id    = local.monitor_action_group_email_name
#      webhook_properties = null
#    },
#    {
#      action_group_id    = local.monitor_action_group_email_name
#      webhook_properties = null
#    }
#  ]
#
#  network_rulesets = [
#    {
#      default_action                 = "Deny"
#      trusted_service_access_enabled = true
#      virtual_network_rule = [
#        {
#          subnet_id                                       = data.azurerm_subnet.eventhub_snet.id
#          ignore_missing_virtual_network_service_endpoint = false
#        },
#        {
#          subnet_id                                       = data.azurerm_subnet.aks_domain_subnet.id
#          ignore_missing_virtual_network_service_endpoint = false
#        },
#        {
#          subnet_id                                       = data.azurerm_subnet.private_endpoint_snet.id
#          ignore_missing_virtual_network_service_endpoint = false
#        }
#      ]
#      ip_rule = []
#    }
#  ]
#
#  # fixme. defined for backward compatibility, needs to be changed to false
#  public_network_access_enabled = true
#
#  tags = var.tags
#}

resource "azurerm_private_endpoint" "event_hub_idpay_01_private_endpoint" {
  # disabled in PROD
  count               = var.enable.idpay.eventhub_idpay_00 && var.env_short != "p" ? 1 : 0
  name                = "${local.project}-evh-01-private-endpoint"
  location            = var.location
  resource_group_name = local.vnet_core_resource_group_name
  subnet_id           = data.azurerm_subnet.private_endpoint_snet.id

  private_dns_zone_group {
    name = data.azurerm_private_dns_zone.ehub.name
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.ehub.id
    ]
  }

  private_service_connection {
    name                           = "${local.project}-evh-01-private-service-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_eventhub_namespace.event_hub_idpay_namespace_01[0].id
    subresource_names              = ["namespace"]
  }
}

#tfsec:ignore:AZU023
resource "azurerm_key_vault_secret" "event_hub_keys_idpay_01" {
  for_each = merge([for hub in var.eventhubs_idpay_01 : { for policy in hub.policies : policy.name => { hub_name = hub.name, policy = policy } }]...)

  name = format("evh-%s-%s-idpay-01", replace(each.key, ".", "-"), "jaas-config")
  value = format(local.jaas_config_template_idpay, azurerm_eventhub_authorization_rule.event_hub_idpay_01_policy[each.key].primary_connection_string)
  content_type = "text/plain"

  key_vault_id = module.key_vault_idpay.id
}
