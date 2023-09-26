# Select environment for proper ocm and backplane configuration.
# Expects both config files for the same environment to have the same names.
# prepare with:
# `touch ~/.config/{ocm,backplane}/config.{prod,stage}.json`
# and don't forget to set up proper proxy and api urls in backplane
function ocm-select-config() {
	find ~/.config/ocm -name "*.json" | fzf |
		while IFS= read -r line; do
			export OCM_CONFIG="$line"
			export BACKPLANE_CONFIG="$HOME/.config/backplane/$(basename "$line")"
		done
}

if [[ -f $(command -v jira) ]]; then
  export JIRA_AUTH_TYPE=bearer
fi

function ocm-list-org-subscriptions-active() {
  if [[ "$1" == "" ]]; then
    echo "usage: $0 <orgid>"
    return 1
  fi

  echo "listing orgs for $1" > /dev/stderr

  ocm get /api/accounts_mgmt/v1/subscriptions\?search="organization_id like '$1'" \
    | yq -Po yaml \
      '.items | filter(.status != "Deprovisioned") | map(pick(["display_name", "id", "cluster_id", "status"]))'

}

# extracts organization id from current login, then queries active subscriptions for this org
function ocm-list-my-org-subscriptions() {
  ocm-list-org-subscriptions-active "$(ocm whoami | yq -r '.organization.id')"
}

function ocm-get-cluster-status() {
  ocm get cluster "$1" | yq -Po yaml .status
}

function ocm-wait-cluster-ready() {
  echo "waiting for cluster $1 to be ready:"
  echo "\n"

  while true; do
    local state="$(ocm-get-cluster-status "$1" | yq -r '.state')"
    if [[ "$state" == "ready" ]]; then
      echo -e "$(date) cluster is ready"
      return 0
    fi
    echo "$(tput cuu1)$(date) cluster is not ready$(tput el)"
    sleep 1
  done
}

function ocm-list-hypershift-management-clusters() {
  ocm list cluster --managed --parameter search="name like 'hs-mc-%'"
}

function ocm-extend-cluster-lifetime-by-days() {
  printf '{\n\t"expiration_timestamp": "%s"\n}\n' \
    "$(date --iso-8601=seconds -d "+$2 days")" \
    | ocm patch "/api/clusters_mgmt/v1/clusters/$1"
}

function ocm-extend-cluster-lifetime-week() {
  ocm-extend-cluster-lifetime-by-days "$1" "7"
}
