# ask-ai.ps1 - Query an LLM via OpenRouter from PowerShell
# Usage: ask "Your question here"

function ask {
    param(
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$QuestionParts
    )

    # Join all arguments into a single question
    $Question = $QuestionParts -join " "

    # Get the directory where this script is located
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        $scriptDir = Get-Location
    }

    # Load .env file from project root if it exists
    $envPath = Join-Path -Path $scriptDir -ChildPath ".env"
    if (Test-Path $envPath) {
        Get-Content $envPath | ForEach-Object {
            if ($_ -match "^\s*([^=]+)=(.*)$") {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                # Remove quotes if present
                $value = $value -replace '^["'']|["'']$', ''
                [Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }

    # Configuration
    $apiKey = $env:OPENROUTER_API_KEY
    $model = if ($env:OPENROUTER_MODEL) { $env:OPENROUTER_MODEL } else { "google/gemini-2.5-flash-lite" }
    $apiUrl = "https://openrouter.ai/api/v1/chat/completions"

    # Check if API key is set
    if ([string]::IsNullOrEmpty($apiKey)) {
        Write-Error "OPENROUTER_API_KEY not set. Please set it as an environment variable or in .env file."
        return
    }

    # Prepare the request body
    $body = @{
        model = $model
        messages = @(
            @{
                role = "system"
                content = "Be concise and direct in your responses, unless directed otherwise."
            },
            @{
                role = "user"
                content = $Question
            }
        )
    } | ConvertTo-Json

    # Call OpenRouter API
    try {
        $response = Invoke-RestMethod -Uri $apiUrl `
            -Method Post `
            -Headers @{
                "Authorization" = "Bearer $apiKey"
                "Content-Type" = "application/json"
            } `
            -Body $body `
            -ErrorAction Stop

        # Extract and print the answer
        if ($response.choices -and $response.choices[0].message.content) {
            Write-Output $response.choices[0].message.content
        } else {
            Write-Error "Failed to get a valid response from the API."
            Write-Error "Response: $($response | ConvertTo-Json)"
        }
    } catch {
        Write-Error "API request failed: $_"
        # Try to extract error details
        try {
            $errorResponse = $_ | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($errorResponse) {
                Write-Error "Error details: $($errorResponse | ConvertTo-Json)"
            }
        } catch {
            # If that fails, try to get the raw response
            Write-Error "Full error: $($_.Exception | Format-List * -Force | Out-String)"
        }
    }
}
