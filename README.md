# ask-ai

A lightweight CLI tool for querying LLMs directly from your terminal. Powered by [OpenRouter](https://openrouter.ai).

## Features

- 🚀 Quick question-answering from the terminal
- 🔧 Works in both **Bash** (including Git Bash on Windows) and **PowerShell**
- 🎯 Concise, direct responses (configurable)
- ⚙️ Simple environment-based configuration
- 📝 No quotes required for multi-word questions
- 🔌 Uses [OpenRouter API](https://openrouter.ai) for LLM access

## Setup

### 1. Get an OpenRouter API Key

1. Visit [https://openrouter.ai/settings/keys](https://openrouter.ai/settings/keys)
2. Create a new API key
3. Copy the key to your clipboard

### 2. Configure the Tool

Create a `.env` file in this project root:

```bash
cp .env.example .env
```

Edit `.env` and paste your API key:

```env
OPENROUTER_API_KEY=your_api_key_here
OPENROUTER_MODEL=google/gemini-2.5-flash-lite
```

The `OPENROUTER_MODEL` variable is optional and defaults to `google/gemini-2.5-flash-lite`.

## Usage

### Bash

Add this to your `~/.bashrc` or `~/.bash_profile`:

```bash
source /path/to/ask-ai/ask-ai.sh
```

Then reload your shell:

```bash
source ~/.bashrc
```

### PowerShell

Add this to your PowerShell profile (find location with `$PROFILE`):

```powershell
. "C:\path\to\ask-ai\ask-ai.ps1"
```

Reload your profile:

```powershell
& $PROFILE
```

## Examples

```bash
ask how to list docker containers
ask what is the capital of france
ask explain recursion in simple terms
```

You can also use quotes:

```bash
ask "How do I install Node.js on Ubuntu?"
```

## Configuration

### Environment Variables

- **`OPENROUTER_API_KEY`** (required): Your OpenRouter API key
- **`OPENROUTER_MODEL`** (optional): The LLM model to use. Defaults to `google/gemini-2.5-flash-lite`

Both variables can be set in `.env` or as environment variables in your shell.

### Changing the Model

To use a different model, update `OPENROUTER_MODEL` in `.env`:

```env
OPENROUTER_MODEL=meta-llama/llama-3.1-70b-instruct
```

Or set it temporarily in your shell:

```bash
export OPENROUTER_MODEL=openai/gpt-4o
ask your question here
```

## How It Works

1. Loads the `.env` file from the project root
2. Sends your question to OpenRouter's API with the configured model
3. Returns the LLM's response directly to your terminal
4. Properly handles multiline responses with formatting

## Requirements

- **Bash**: `bash`, `curl`
- **PowerShell**: PowerShell 5.0+

## Troubleshooting

### API Key Not Found

Ensure your `.env` file is in the same directory as the scripts and contains:

```env
OPENROUTER_API_KEY=your_key_here
```

### "API request failed" Error

1. Check that your API key is valid at [https://openrouter.ai/settings/keys](https://openrouter.ai/settings/keys)
2. Verify you have credits on your OpenRouter account
3. Check your internet connection

### Quotes or Special Characters Not Working

Try quoting your entire question:

```bash
ask "What does 'hello world' mean?"
```

## License

See [LICENSE](LICENSE) file for details.
