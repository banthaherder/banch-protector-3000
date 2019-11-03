resource "github_organization_webhook" "branch_protector_3000" {
  configuration {
    url          = "https://githook.dev.banthacloud.com/github"
    content_type = "json"
    insecure_ssl = true
  }

  active = true

  events = ["repository"]
}
