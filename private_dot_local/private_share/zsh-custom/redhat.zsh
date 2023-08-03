# prepare with:
# `touch ~/.config/ocm/config.{prod,stage}.json`
# and don't forget to set proper proxy and api urls
function backplane-select-config() {
	find ~/.config/backplane -name "*.json" | fzf |
		while IFS= read -r line; do
			export BACKPLANE_CONFIG="$line"
		done
}

# prepare with:
# `touch ~/.config/ocm/ocm.{prod,stage}.json`
function ocm-select-config() {
	find ~/.config/ocm -name "*.json" | fzf |
		while IFS= read -r line; do
			export OCM_CONFIG="$line"
		done
}
