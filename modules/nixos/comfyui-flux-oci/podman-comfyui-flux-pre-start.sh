until podman network inspect comfyui-flux-oci_default >/dev/null 2>&1; do
  echo "Waiting for network comfyui-flux-oci_default to be created..."
  sleep 5
done
