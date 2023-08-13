###
# suffix aliases
###
alias -s git="git clone"

###
# aliases
###
alias date-iso="date --utc +%FT%T.%3NZ"
alias create-nvmrc="node --version | tr -d 'v' > .nvmrc"
# alias ping="prettyping"
alias copy="xsel -bi"
alias pasta="xsel -bo"
alias termbin="nc termbin.com 9999"

# fzf-preview jq on all json files
alias fzf-jq="echo '' | fzf --print-query --preview 'cat *.json | jq {q}'"

# start ipython shell in current venv
alias ipy="python -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"

# remove ansi color data from piped data
alias stripcolors='sed "s/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g"'

alias ssh-keygen-to-stdout="echo /tmp/stderr{,.pub} | xargs -n 1 ln -sf /dev/stderr && yes | ssh-keygen -t ed25519 -N '' -qf /tmp/stderr > /dev/null"

function ssh-keys-from-github() {
	for user in "$@"
	do
		echo "# `date` GitHub Keys for user '$user':"
		curl -qs "https://github.com/$user.keys"
	done
}

###
# functions
###

function auropen() { gio open "https://aur.archlinux.org/packages/$1" }

###
## GUI
###

# run a gui command in bg from the terminal witouth seeing stdout and stderr
function run-gui() {
	$1>/dev/null 2>&1 &
}

###
## NETWORKING
###

# get and show external network ip
function get-ext-ip() {
	echo "$(curl -s https://ip.werise.de)"
}

# fzf *.ovpn files in current folder, select one and start ovpn with it
function openvpn-select-config() {
	find . -name "*.ovpn" | fzf |
		while IFS= read -r line; do
			sudo xargs openvpn --config "$line"
		done
}


###
## SSL
###

# show lifetime of an https certificate
function test-ssl-cert-lifetime {
    echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -dates
}

# download https certificate
function get-ssl-cert {
    echo | openssl s_client -connect $1:443 -servername $1 -prexit 2>/dev/null | sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p'
}

###
## MEDIA
###

# download mp3
function download-mp3 {
    youtube-dl -x --audio-format mp3 "$1"
}
