#
# IDPAY API MOCK EXTERNAL SERVICE FOR INPS
#

## IDPAY MOCK External Services for INPS API ##
module "idpay_mock_ex_serv_inps" {
  source = "git::https://github.com/pagopa/azurerm.git//api_management_api?ref=v2.18.2"

  count = var.enable_pdnd_api_mock ? 1 : 0

  name                = "${var.env_short}-idpay_mock_ex_serv_inps"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY MOCK External Services for INPS"
  display_name = "IDPAY MOCK External Services for INPS API"
  path         = "mock-ex-serv-inps"
  protocols    = ["https"]

  service_url = "http://${var.ingress_load_balancer_hostname}/idpay/mock-ex-serv-inps"

  content_format = "wsdl"
  content_value  = file("./api/idpay_mock_ex_serv_inps/inps-isee.wsdl")

  xml_content = file("./api/base_policy.xml")

  api_operation_policies = [
    {
      operation_id = "ConsultazioneIndicatore"
      xml_content = templatefile("./api/idpay_mock_ex_serv_inps/post-inps.xml.tpl", {
        ingress_load_balancer_hostname = var.ingress_load_balancer_hostname
      })
    }
  ]

}


####

locals {
  api_operation_policies = [
    {
      operation_id = "ConsultazioneIndicatore"
      xml_content = templatefile("./api/idpay_mock_ex_serv_inps/post-inps.xml.tpl", {
        ingress_load_balancer_hostname = var.ingress_load_balancer_hostname
      })
    }
  ]
}


resource "azurerm_api_management_api" "idpay_mock_ex_serv_inps" {
  name                 = "${var.env_short}-idpay_mock_ex_serv_inps"
  resource_group_name  = data.azurerm_resource_group.apim_rg.name
  api_management_name  = data.azurerm_api_management.apim_core.name
  revision             = "1"
  revision_description = null
  display_name         = "IDPAY MOCK External Services for INPS API"
  description          = "IDPAY MOCK External Services for INPS"

  path                  = "mock-ex-serv-inps"
  protocols             = ["https"]
  service_url           = "http://${var.ingress_load_balancer_hostname}/idpay/mock-ex-serv-inps"
  subscription_required = var.subscription_required #Deve essere false

  import {
    content_format = "wsdl"
    content_value  = file("./api/idpay_mock_ex_serv_inps/inps-isee.wsdl")
  }

}

resource "azurerm_api_management_api_policy" "idpay_mock_ex_serv_inps" {
  api_name            = azurerm_api_management_api.idpay_mock_ex_serv_inps.name
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  xml_content = file("./api/base_policy.xml")
}

resource "azurerm_api_management_api_operation_policy" "api_operation_policy" {
  for_each = { for p in local.api_operation_policies : p.operation_id => p }

  api_name            = azurerm_api_management_api.idpay_mock_ex_serv_inps.name
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name
  operation_id        = each.value.operation_id

  xml_content = each.value.xml_content
}