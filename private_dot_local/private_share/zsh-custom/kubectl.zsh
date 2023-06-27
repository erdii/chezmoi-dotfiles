if [[ -f "$(command -v kubectl)" ]]; then
  function kubectl-apply-secret() {
    local name="$1"
    local filepath="$2"

    if [[ -z "$name" || -z "$filepath" ]]; then
      echo "kubectl-apply-secret secret-name file-path [kubectl arguments...]"
      echo "examples:"
      echo "\tkubectl-apply-secret name path/to/folder/or/file"
      echo "\tkubectl-apply-secret name path/to/folder/or/file -n foo"
      return
    fi
    shift
    shift

    kubectl create secret generic "$name" \
      --save-config --dry-run=client \
      --from-file="$filepath" \
      -o yaml \
      "$@" | kubectl apply -f -
  }

  function kubeconfig-remove() {
    if [[ -f "$KUBECONFIG" ]]; then
      rm $KUBECONFIG
      unset KUBECONFIG
    fi
  }

  alias kas="kubectl-apply-secret"
  alias kw="watch kubectl"

  function kexport() {
    export KUBECONFIG="$1"
  }

  function kunset() {
    unset KUBECONFIG
  }

  function konsole() {
    local node="$(kubectl get node --label-columns=kubernetes.io/hostname | fzf | awk '{print $6}')"
    if [[ -z "$node" ]]; then
      echo "no node found"
      return 1
    fi

    local ns="$(kubectl get ns | fzf | awk '{print $1}')"
    if [[ -z "$ns" ]]; then
      echo "no namespace found"
      return 1
    fi

    local image=docker.io/nicolaka/netshoot
    local name=konsole-$RANDOM
    local overrides='{"spec": {
  "hostPID": true,
  "tolerations": [{"operator": "Exists", "effect": "NoSchedule"}, {"operator": "Exists", "effect": "NoExecute"}],
  "containers": [{
    "name": "'$name'",
    "image": "'$image'",
    "command": ["/bin/sh"],
    "args": ["-c", "nsenter -t 1 -m -u -i -n -p -- bash"],
    "stdin": true,
    "stdinOnce": true,
    "terminationMessagePath": "/dev/termination-log",
    "terminationMessagePolicy": "File",
    "tty": true,
    "securityContext": {"privileged": true}
  }],
  "nodeSelector": {"kubernetes.io/hostname": "'$node'"}
}}'

    kubectl run "$name" --namespace "$ns" --rm -it --image "$image" --overrides="${overrides}"
  }
fi
