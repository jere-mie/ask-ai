#!/bin/bash

# ask-ai.sh - Query an LLM via OpenRouter from the terminal
# Usage: ask "Your question here"

ask() {
    # Get the directory where this script is located
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Load .env file from project root if it exists
    if [ -f "$SCRIPT_DIR/.env" ]; then
        set -a
        source "$SCRIPT_DIR/.env"
        set +a
    fi

    # Configuration
    local API_KEY="${OPENROUTER_API_KEY}"
    local MODEL="${OPENROUTER_MODEL:-google/gemini-2.5-flash-lite}"
    local API_URL="https://openrouter.ai/api/v1/chat/completions"

    # Check if API key is set
    if [ -z "$API_KEY" ]; then
        echo "Error: OPENROUTER_API_KEY not set. Please set it as an environment variable or in .env file." >&2
        return 1
    fi

    # Check if a question was provided
    if [ $# -eq 0 ]; then
        echo "Usage: ask your question here" >&2
        return 1
    fi

    # Join all arguments into a single question
    local QUESTION="$*"

    # Call OpenRouter API
    local RESPONSE=$(curl -s -X POST "$API_URL" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {
                    \"role\": \"system\",
                    \"content\": \"Be concise and direct in your responses, unless directed otherwise.\"
                },
                {
                    \"role\": \"user\",
                    \"content\": \"$QUESTION\"
                }
            ]
        }")

    # Extract the response content
    # Use sed to extract the content field and unescape the JSON string
    local ANSWER=$(echo "$RESPONSE" | sed -n 's/.*"content":"\([^"]*\)".*/\1/p' | head -1)
    
    # Unescape common JSON escape sequences
    ANSWER=$(echo -e "$ANSWER" | sed 's/\\n/\n/g' | sed 's/\\t/\t/g' | sed 's/\\r/\r/g' | sed 's/\\\//\//g' | sed 's/\\"/"/g' | sed "s/\\\\'/'/g")

    # Check if we got a valid response
    if [ -z "$ANSWER" ]; then
        echo "Error: Failed to get a response from the API." >&2
        echo "Response: $RESPONSE" >&2
        return 1
    fi

    # Print the answer
    echo -e "$ANSWER"
}
