<!--
    IMPORTANT:
    - Policy elements can appear only within the <inbound>, <outbound>, <backend> section elements.
    - To apply a policy to the incoming request (before it is forwarded to the backend service), place a corresponding policy element within the <inbound> section element.
    - To apply a policy to the outgoing response (before it is sent back to the caller), place a corresponding policy element within the <outbound> section element.
    - To add a policy, place the cursor at the desired insertion point and select a policy from the sidebar.
    - To remove a policy, delete the corresponding policy statement from the policy document.
    - Position the <base> element within a section element to inherit all policies from the corresponding section element in the enclosing scope.
    - Remove the <base> element to prevent inheriting policies from the corresponding section element in the enclosing scope.
    - Policies are applied in the order of their appearance, from the top down.
    - Comments within policy elements are not supported and may disappear. Place your comments between policy elements or at a higher level scope.
-->
<policies>
    <inbound>
        <base />
        <return-response>
            <set-status code="200" reason="OK" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>@{
            Random rnd = new Random();
            int num = rnd.Next(0,2);
            string[] city = {"Milano", "Roma"};
            string[] cap = {"20124", "00187"};
            string[] sigla = {"MI", "RM"};
            int age = rnd.Next(18,99);
            var now = System.DateTime.Now;
            var birthDate = now.AddYears(-age);
            var year = birthDate.Year;
            return new JObject(
                    new JProperty("listaSoggetti",
                      new JObject(
                        new JProperty("datiSoggetto",
                          new JArray(
                            new JObject(
                              new JProperty("generalita",
                                new JObject(
                                  new JProperty("codiceFiscale",
                                    new JObject(
                                      new JProperty("codFiscale", "fiscalCode")
                                    )
                                  ),
                                  new JProperty("cognome", "lastName"),
                                  new JProperty("nome", "name"),
                                  new JProperty("dataNascita", string.Concat(year, "-01-01")),
                                  new JProperty("senzaGiornoMese", year)
                                )
                              ),
                              new JProperty("residenza",
                                new JArray(
                                  new JObject(
                                    new JProperty("indirizzo",
                                      new JObject(
                                        new JProperty("cap", cap[num]),
                                        new JProperty("comune",
                                          new JObject(
                                            new JProperty("nomeComune", city[num]),
                                            new JProperty("siglaProvinciaIstat", sigla[num])
                                          )
                                        )
                                      )
                                    )
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  ).ToString();
          }</set-body>
        </return-response>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>