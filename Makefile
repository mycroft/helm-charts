HELM_DOCS_VERSION  ?= v1.14.2
KUBECONFORM_VERSION ?= v0.7.0
K8S_VERSION        ?= 1.31.4
BIN                := $(CURDIR)/bin
CHARTS             := $(patsubst charts/%/Chart.yaml,%,$(wildcard charts/*/Chart.yaml))

export PATH := $(BIN):$(PATH)

.PHONY: help
help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk -F':.*?## ' '{printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

.PHONY: lint
lint: ## helm lint every chart
	@for c in $(CHARTS); do helm lint charts/$$c; done

.PHONY: template
template: ## Render every chart with its default values
	@for c in $(CHARTS); do helm template release-name charts/$$c > /dev/null && echo "ok $$c"; done

.PHONY: docs
docs: $(BIN)/helm-docs ## Regenerate chart READMEs from values.yaml
	helm-docs --chart-search-root=charts --sort-values-order=file

.PHONY: kubeconform
kubeconform: $(BIN)/kubeconform ## Validate rendered manifests (K8S_VERSION=x.y.z)
	./scripts/kubeconform.sh $(K8S_VERSION)

.PHONY: check
check: lint template docs kubeconform ## Everything CI runs, minus the kind install
	@git diff --exit-code -- charts \
		|| { echo "Chart READMEs were stale; they have been regenerated — commit them."; exit 1; }

.PHONY: clean
clean: ## Remove downloaded tools and packaged charts
	rm -rf $(BIN) .cr-release-packages

$(BIN)/helm-docs:
	@mkdir -p $(BIN)
	curl -sSLf "https://github.com/norwoodj/helm-docs/releases/download/$(HELM_DOCS_VERSION)/helm-docs_$(patsubst v%,%,$(HELM_DOCS_VERSION))_Linux_x86_64.tar.gz" \
		| tar -xz -C $(BIN) helm-docs

$(BIN)/kubeconform:
	@mkdir -p $(BIN)
	curl -sSLf "https://github.com/yannh/kubeconform/releases/download/$(KUBECONFORM_VERSION)/kubeconform-linux-amd64.tar.gz" \
		| tar -xz -C $(BIN) kubeconform
