# If you come frm bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster" # set by `omz`

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git nmap sudo tailscale)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#!/usr/bin/env zsh

# Get distribution name
#function distribution() {
#    typeset -g distr="Unknown"
#
#    if [ -r /etc/os-release ]; then
#        source /etc/os-release
#        case "$ID" in
#            ubuntu|debian) distr="debian" ;;
#            fedora|centos|rhel) distr="redhat" ;;
#            arch|manjaro) distr="arch" ;;
#            gentoo) distr="gentoo" ;;
#            alpine) distr="alpine" ;;
#            opensuse) distr="opensuse" ;;
#            *) distr="$ID" ;;
#        esac
#}

# Show OS Version
#function ver() {
#    if [ "$distr" = "Unknown" ]; then
#        echo "OS version not available."
#        return 1
#    fi
#
#    if [ -n $PRETTY_NAME ]; then
#        echo "$PRETTY_NAME"
#    elif [ -n "$NAME" ] && [ -n "$VERSION_ID" ]; then
#        echo "$NAME $VERSION_ID"
#    else
#        echo "No version information available."
#    fi
#}

# Check outbound email connectivity to a given SMTP server
#
# Parameters:
#   $1: The hostname of the SMTP server to test. If not provided, the user
#          will be prompted to enter one.
#
# Notes:
#   The function will test the following ports: 25, 587, 465, 2525
#   The function will timeout after 3 seconds if a connection is not established.
#   The function will output the results in a colored format for easy identification.
#   If the connection is refused, the function will output a message indicating that the
#     service is likely not listening or that a firewall is blocking the connection.
#   If the connection times out, the function will output a message indicating that the
#     firewall is likely dropping the connection packets.
function checksmtp() {
    local HOST_ARG="$1"
    local PORTS=(25 587 465 2525)
    local TIMEOUT=3
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color

    # Convert the host argument to lowercase to avoid case sensitivity before mapping
    HOST_ARG=$(echo "$HOST_ARG" | tr '[:upper:]' '[:lower:]')    
    case "$HOST_ARG" in
        "smtp2go") HOST="smtp.smtp2go.com" ;;
        "sendgrid") HOST="smtp.sendgrid.net" ;;
        "mailgun") HOST="smtp.mailgun.org" ;;
        "postmark") HOST="smtp.postmarkapp.com" ;;
        "amazon" | "ses") HOST="email-smtp.us-east-1.amazonaws.com" ;;
        "brevo" | "sendinblue") HOST="smtp-relay.sendinblue.com" ;;
        "gmail") HOST="smtp.gmail.com" ;;
        "office365" | "o365" | "outlook" | "microsoft") HOST="smtp.office365.com" ;;
        *) HOST="$HOST_ARG"
            ;;
    esac

    echo "--- Testing Outbound Connectivity to $HOST ---"

    for PORT in "${PORTS[@]}"; do
        echo -n "Executing nc -zvw $TIMEOUT $HOST $PORT... "
        
        # Use nc (Netcat) with a timeout and quiet mode (-w, -z)
        # We redirect stderr (2) to /dev/null to hide connection refusal noise
        if nc -zvw $TIMEOUT "$HOST" "$PORT" 2> /dev/null; then
            echo -e "[${GREEN}OPEN${NC}]"
        else
            # Check for a specific 'Connection refused' error (exit code 1)
            if [ $? -eq 1 ]; then
                echo -e "[${RED}BLOCKED/CLOSED${NC}] - Service is likely not listening or firewall is blocking."
            else
                echo -e "[${RED}TIMEOUT${NC}] - Firewall is likely dropping the connection packets."
            fi
        fi
    done
}

# What is my IP?
function whatsmyip() {
    echo "--- Local (Internal) IPs ---"

    # LOCAL IPv4 and IPv6
    if command -v ip > /dev/null; then
        echo "Local IPv4:"
        ip -4 addr show scope global | grep -oP 'inet \K[\d.]+'

        echo "Local IPv6 (Global Scope):"
        ip -6 addr show scope global | grep -oP 'inet6 \K[\da-f:]+' | grep -v '::1'
    elif command -v ifconfig > /dev/null; then
        echo "Local IPv4 (via ifconfig):"
        ifconfig | grep -Eo 'inet (addr:)?([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $2}' | grep -v '127.0.0.1'
        echo "Note: ip command is recommended for complete IPv6 local addressing."
    else
        echo "Neither ip nor ifconfig found."
    fi

    echo ""
    echo "--- External (Public) IPs ---"

    # EXTERNAL IPv4 and IPv6
    if command -v curl > /dev/null || command -v wget > /dev/null; then

        echo "Public IPv4:"
        if command -v curl > /dev/null; then
            printf "%s\n" "$(curl -4 -s ifconfig.me 2>/dev/null)" || echo "Error/No Public IPv4."
        elif command -v wget > /dev/null; then
            printf "%s\n" "$(wget -4 -qO- ifconfig.me 2>/dev/null)" || echo "Error/No Public IPv4."
        fi

        echo "Public IPv6:"
        IPV6_RESULT=""
        if command -v curl > /dev/null; then
            IPV6_RESULT=$(curl -6 -s checkip.amazonaws.com 2>/dev/null)
        elif command -v wget > /dev/null; then
            IPV6_RESULT=$(wget -6 -qO- checkip.amazonaws.com 2>/dev/null)
        fi

        if [ -n "$IPV6_RESULT" ]; then
            printf "%s\n" "$IPV6_RESULT"
        else
            echo "No Public IPv6 connectivity detected."
        fi

    else
        echo "Neither curl nor wget found."
    fi
}

# Editor Configuration
if command -v code-insiders &> /dev/null; then
    export EDITOR='code --wait'
elif command -v nvim &> /dev/null; then
    export EDITOR='nvim'
else
    export EDITOR='vi'
fi

# Edit .zshrc
function edit-profile() {
    $EDITOR ~/.zshrc
}
alias ep='edit-profile'

# Reload .zshrc
function reload-zsh() {
    source ~/.zshrc
}

# aliases
alias cls='clear'               # clear the terminal
alias ls='eza'                  # use eza for ls
alias py='python3'              # use python3 as default python
alias vi='nvim'

# function aliases
alias myip='whatsmyip'

# directory aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias home='cd ~'
alias config='cd ~/.config'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'
alias apache='cd /etc/apache2'
alias web='cd /var/www/html'

# z aliases
alias z..='zoxide query ..'
alias z...='zoxide query ../..'
alias z....='zoxide query ../../..'
alias z.....='zoxide query ../../../..'

# process management
alias p='ps aux | grep -v grep' # search processes
alias ps='ps auxf'              # show processes
alias top='htop'                # show system monitor
alias topcpu='/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10' # top CPU processes

# relative directory navigation
alias bd='cd $OLDPWD'

# extract archives
function extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)  command -v tar &> /dev/null && tar xvjf "$1" || echo "tar command not found." ;;
            *.tar.gz)   command -v tar &> /dev/null && tar xvzf "$1" || echo "tar command not found." ;;
            *.tar.xz)   command -v tar &> /dev/null && tar xvJf "$1" || echo "tar command not found." ;;
            *.tar)      command -v tar &> /dev/null && tar xvf "$1" || echo "tar command not found." ;;
            *.zip)      command -v unzip &> /dev/null && unzip "$1" || echo "unzip command not found." ;;
            *.rar)      command -v unrar &> /dev/null && unrar x "$1" || echo "unrar command not found." ;;
            *.7z)       command -v 7z &> /dev/null && 7z x "$1" || echo "7z command not found." ;;
            *)          echo "Cannot extract '$1' - unsupported file type." ;;
        esac
    else
        echo "'$1' is not a valid file."
    fi
}

cheat() { clear && curl cheat.sh/"$1" ; }

weather() { clear && curl wttr.in/"$1" ; }

export PATH="$PATH:/home/user/bin"
export PATH="$PATH:/snap/bin"
export PATH=$PATH:/usr/local/go/bin
eval "$(zoxide init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
