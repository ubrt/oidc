Import-Module ./OIDC.psd1

# Example for keycloak 
$issuerUrl="http://localhost:8080/realms/master/"
$clientId="powershell"
$clientSecret="yLFbpDi1adVMCPrUGYca4zdjX9Wn5nkJ"

Get-OIDCToken -issuerUrl $issuerUrl -clientId $clientId -clientSecret $clientSecret