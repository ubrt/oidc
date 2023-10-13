<#
 .Synopsis
  Gets tokens via oAuth2 code flow with optional pkce

 .Description
  This is a helper module to get tokens via the authorization code grant as described in rfc6749

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
  Disables the proof key for code exchange. This should only disable if the authority doesn't support pkce.

 .Example
   # Request a set of tokens
   Get-OIDCToken -issuerUrl https://issuer.base -clientId 12345 -clientSecret "secret"
#>
function Get-OIDCToken {
    param(
        [Parameter(Mandatory = $true)][string] $issuerUrl,
        [Parameter(Mandatory = $true)][string] $clientId,
        [string] $clientSecret = "",
        [string] $scopes = "openid",
        [int] $callbackPortBinding = 64433,
        [switch] $disablePKCE
    )

    $uris = Get-UrisFromDiscovery -discoveryEndpoint ($issuerUrl + ".well-known/openid-configuration")
    $authUrl = "$($uris.authEndpoint)?client_id=$clientId&response_type=code&scope=$scopes&redirect_uri=http://localhost:$callbackPortBinding/"
        
    if (-not $disablePKCE) {
        $challenge = Get-PKCEChallenge
        $authUrl += "&code_challenge=$($challenge.codeChallenge)&code_challenge_method=$($challenge.method)"
    }

    Start-Process $authUrl
        
    $code = Get-CodeFromCallback -callbackPortBinding $callbackPortBinding

    $body = @{
        code         = $code
        grant_type   = "authorization_code"
        client_id    = $clientId
        redirect_uri = "http://localhost:$callbackPortBinding/"
    }
    if (-not $disablePKCE) {
        $body['code_verifier'] = $challenge.codeVerifier
    }
    if ($clientSecret -ne "") {
        $body['client_secret'] = $clientSecret
    }
    Invoke-RestMethod -Method 'Post' -Uri $uris.tokenEndpoint -Body $body
}

function Get-PKCEChallenge {
    
    $codeVerifier = Get-RandomBase64String
    $codeChallenge = Get-CodeChallenge -codeVerifier $codeVerifier

    @{
        "codeVerifier"  = $codeVerifier;
        "codeChallenge" = $codeChallenge;
        "method"        = "S256"
    }
}

function Get-RandomBase64String {
    $codeVerifierBytes = New-Object byte[] 32
    $random = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $random.GetBytes($codeVerifierBytes)
    [Convert]::ToBase64String($codeVerifierBytes) -replace '\+', '-' -replace '/', '_' -replace '=', ''
}

function Get-CodeChallenge {
    param(
        [Parameter(Mandatory = $true)][string] $codeVerifier
    )
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $codeVerifierBytes = [System.Text.Encoding]::UTF8.GetBytes($codeVerifier)
    $codeChallengeBytes = $sha256.ComputeHash($codeVerifierBytes)
    $codeChallenge = [Convert]::ToBase64String($codeChallengeBytes)
    $codeChallenge -replace '\+', '-' -replace '/', '_' -replace '=', ''
}

function Get-UrisFromDiscovery {
    param(
        [Parameter(Mandatory = $true)][string] $discoveryEndpoint
    )
    $discoveryResponse = Invoke-RestMethod -Method 'Get' -Uri $discoveryEndpoint

    @{
        'authEndpoint'  = $discoveryResponse.authorization_endpoint;
        'tokenEndpoint' = $discoveryResponse.token_endpoint
    }
}

function Get-CodeFromCallback {
    param(
        [Parameter(Mandatory = $true)][int] $callbackPortBinding
    )
    $httpListener = New-Object System.Net.HttpListener
    $httpListener.Prefixes.Add("http://localhost:$callbackPortBinding/")
    $httpListener.Start()
    $context = $httpListener.GetContext()
    $query = $context.Request.Url.Query
    $context.Response.StatusCode = 200
    $context.Response.ContentType = 'text/html; charset=utf-8'
    $responseHTML = '<html><head><script>window.setTimeout(() => window.close(),200);</script></head></html>'
    $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($responseHTML)
    $context.Response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
    $context.Response.Close()
    $httpListener.Stop()
    $queryParameters = [System.Web.HttpUtility]::ParseQueryString($query)
    $queryParameters['code']
}

Export-ModuleMember -Function Get-OIDCToken