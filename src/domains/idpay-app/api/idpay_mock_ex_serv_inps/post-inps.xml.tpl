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
                <value>text/xml</value>
            </set-header>
            <set-body>@{
            Random rnd = new Random();
            int iseeRandom = rnd.Next(1000, 100000);
            var indicatoreBegin = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" + "\n" + "<Indicatore ISEE=\"";
            var indicatoreEnd = "\" xmlns=\"http://inps.it/ISEERiforma\"/>\n";
            var indicatoreConcat = string.Concat(indicatoreBegin, iseeRandom);
            var indicatoreFinal = string.Concat(indicatoreConcat, indicatoreEnd);
            var indicatoreBase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(indicatoreFinal));
            //.Split('=')[0].Replace('+', '-').Replace('/', '_');
            var soapStringBegin = "<s11:Envelope xmlns:s11=\"http://schemas.xmlsoap.org/soap/envelope/\"><s11:Body><ns1:ConsultazioneIndicatoreResponse xmlns:ns1=\"http://inps.it/ConsultazioneISEE\"><!-- optional --><ns1:ConsultazioneIndicatoreResult><ns1:IdRichiesta>?999?</ns1:IdRichiesta><!-- possible value: OK, possible value: RICHIESTA_INVALIDA, possible value: DATI_NON_TROVATI, possible value: DATABASE_OFFLINE, possible value: ERRORE_INTERNO, possible value: RISCONTRO_NON_VALIDO --><ns1:Esito>OK</ns1:Esito><!-- optional --><ns1:DescrizioneErrore>?XXX?</ns1:DescrizioneErrore><!-- optional --><ns1:XmlEsitoIndicatore>";
            var soapStringEnd = "</ns1:XmlEsitoIndicatore></ns1:ConsultazioneIndicatoreResult></ns1:ConsultazioneIndicatoreResponse></s11:Body></s11:Envelope>";
            var soapStringConcat = string.Concat(soapStringBegin, indicatoreBase64);
            var soapStringFinal = string.Concat(soapStringConcat, soapStringEnd);
            //PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9InllcyI/Pgo8SW5kaWNhdG9yZSBJU0VFPSIxMDAwMCIgeG1sbnM9Imh0dHA6Ly9pbnBzLml0L0lTRUVSaWZvcm1hIi8+Cg==
            return soapStringFinal;
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