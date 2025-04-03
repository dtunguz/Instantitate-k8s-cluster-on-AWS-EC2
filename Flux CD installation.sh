Flux CD installation

kubectl taint nodes --all node-role.kubernetes.io/control-plane-

//// token: <github_token>

curl -s https://fluxcd.io/install.sh | sudo bash
. <(flux completion bash)

export GITHUB_TOKEN=<github_token>
flux bootstrap github \
  --token-auth \
  --owner=dju-t \
  --repository=flux \
  --branch=main \
  --path=clusters/my-cluster \
  --personal

