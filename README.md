# 🐙 Push to GitHub Script

Push any project to GitHub with a single command.

## Features

- One command to push any project
- Auto-creates GitHub repository
- Auto-generates .gitignore
- Auto-configures Git
- Token verification before push
- Connection testing to GitHub API
- Hides token after push (security)

## Requirements

- Termux
- Git
- Curl
- GitHub Token

## Setup

### 1. Create a GitHub Token

1. Go to: https://github.com/settings/tokens/new
2. Note: Termux
3. Expiration: No expiration
4. Scopes: Check repo
5. Click Generate token
6. Copy the token

### 2. Save the Token

    mkdir -p ~/.config/termux-github
    printf '%s' "USERNAME:ghp_YOUR_TOKEN" > ~/.config/termux-github/token.txt
    chmod 600 ~/.config/termux-github/token.txt

### 3. Install the Script

    chmod +x ~/push-to-github.sh
    echo 'alias pg="bash ~/push-to-github.sh"' >> ~/.bashrc

## Usage

    cd ~/your-project-folder
    bash ~/push-to-github.sh repository-name

## Example

    cd ~/projects/python-tools
    bash ~/push-to-github.sh python-tools

## License

MIT License

## Author

Ayman (@ayman7990-tech)
