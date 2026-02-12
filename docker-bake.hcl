variable "TAG" {
  default = "latest"
}

variable "DATE_TAG" {
  default = "latest"
}

variable "REGISTRY" {
  default = "ghcr.io/jessegoodier"
}

group "default" {
  targets = ["common", "aws", "gcp", "azure", "combined", "homebrew"]
}

group "core" {
  targets = ["common", "aws", "gcp", "azure", "combined"]
}

target "common" {
  context = "common"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["${REGISTRY}/toolbox-common:${TAG}", "${REGISTRY}/toolbox-common:${DATE_TAG}"]
}

target "aws" {
  context = "aws"
  dockerfile = "Dockerfile"
  contexts = {
    "toolbox-common" = "target:common"
  }
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["${REGISTRY}/toolbox-aws:${TAG}", "${REGISTRY}/toolbox-aws:${DATE_TAG}"]
}

target "gcp" {
  context = "gcp"
  dockerfile = "Dockerfile"
  contexts = {
    "toolbox-common" = "target:common"
  }
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["${REGISTRY}/toolbox-gcp:${TAG}", "${REGISTRY}/toolbox-gcp:${DATE_TAG}"]
}

target "azure" {
  context = "azure"
  dockerfile = "Dockerfile"
  contexts = {
    "toolbox-common" = "target:common"
  }
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["${REGISTRY}/toolbox-azure:${TAG}", "${REGISTRY}/toolbox-azure:${DATE_TAG}"]
}

target "combined" {
  context = "combined"
  dockerfile = "Dockerfile"
  contexts = {
    "toolbox-common" = "target:common"
  }
  platforms = ["linux/amd64", "linux/arm64"]
  tags = [
    "${REGISTRY}/toolbox-combined:${TAG}",
    "${REGISTRY}/toolbox-combined:${DATE_TAG}",
    "${REGISTRY}/toolbox:${TAG}",
    "${REGISTRY}/toolbox:${DATE_TAG}"
  ]
}

target "homebrew" {
  context = "homebrew"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["${REGISTRY}/toolbox-homebrew:${TAG}", "${REGISTRY}/toolbox-homebrew:${DATE_TAG}"]
}
