# https://github.com/kubernetes-sigs/krew
# installation:
# (
#   set -x; cd "$(mktemp -d)" &&
#   curl -fsSLO "https://storage.googleapis.com/krew/v0.2.1/krew.{tar.gz,yaml}" &&
#   tar zxvf krew.tar.gz &&
#   ./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install \
#     --manifest=krew.yaml --archive=krew.tar.gz
# )

if [[ -d $HOME/.krew ]]; then
  export PATH="$HOME/.krew/bin:$PATH"
fi
