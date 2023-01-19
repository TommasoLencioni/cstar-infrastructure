#
# IDPAY API MOCK EXTERNAL SERVICE FOR ANPR
#

## IDPAY MOCK External Services for ANPR API ##
module "idpay_mock_ex_serv_anpr" {
  source = "git::https://github.com/pagopa/azurerm.git//api_management_api?ref=v2.18.2"

  count = var.enable_pdnd_api_mock ? 1 : 0

  name                = "${var.env_short}-idpay_mock_ex_serv_anpr"
  api_management_name = data.azurerm_api_management.apim_core.name
  resource_group_name = data.azurerm_resource_group.apim_rg.name

  description  = "IDPAY MOCK External Services for ANPR"
  display_name = "IDPAY MOCK External Services for ANPR API"
  path         = "mock-ex-serv-anpr"
  protocols    = ["https"]

  service_url = "http://${var.ingress_load_balancer_hostname}/idpay/mock-ex-serv-anpr"

  content_format = "openapi"
  content_value  = file("./api/idpay_mock_ex_serv_anpr/openapi.mock.ex.serv.anpr.yaml")

  xml_content = file("./api/base_policy.xml")

  api_operation_policies = [
    {
      operation_id = "accertamentoResidenza"
      xml_content = templatefile("./api/idpay_mock_ex_serv_anpr/post-anpr.xml.tpl", {
        ingress_load_balancer_hostname = var.ingress_load_balancer_hostname
      })
    }
  ]

}
