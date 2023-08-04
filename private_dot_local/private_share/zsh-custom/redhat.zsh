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
