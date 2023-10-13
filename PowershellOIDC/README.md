
# Powershell OIDC Module

This is a simple module to request tokens via oauth2/OIDC. This was tested against keycloak, a sample client config is also available in the repo. PKCE can be disabled if the authority does not support it. See the module synopsis for a complete list of all params. 

## Quickstart

```
Import-Module ./OIDC.psm1
$issuerUrl="http://localhost:8080/realms/master/"
$clientId="powershell"
$clientSecret="yLFbpDi1adVMCPrUGYca4zdjX9Wn5nkJ"

Get-OIDCToken -issuerUrl $issuerUrl -clientId $clientId -clientSecret $clientSecret
```

## Callback

This script uses System.Net.HttpListener on Port 64433 to catch the code from the callback response. If this port is already taken on your pc, please specify another port via the -callbackPortBinding parameter. Please also add the local callback url http://localhost:64433/ to the valid redirect uris setting of your identity provider client config.

## Params

 .Parameter issuerUrl
  The base url of the authority

 .Parameter clientId
  The id of the oAuth2 client

 .Parameter clientSecret
  The secret of the oAuth2 client

 .Parameter scopes
  The scopes requested. Defaults to openid.

 .Parameter callbackPortBinding
  A HttpListener is startet on this port to catch the callback. Defaults to 64433

 .Parameter disablePKCE
  Disables the proof key for code exchange. This should only be disabled if the authority doesn't support pkce.

