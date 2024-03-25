## == Create an ISO image using ================================================
## == Talos Image Factory ======================================================

data "http" "talos_image_id" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"

  request_body = file("${path.module}/templates/schematic.yaml")
}
