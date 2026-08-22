# helm-charts

Helm charts published to <https://mycroft.github.io/helm-charts/> and, as OCI
artifacts, to `ghcr.io/mycroft/charts`.

```console
helm repo add mycroft https://mycroft.github.io/helm-charts/
helm repo update
helm search repo mycroft
```

## Charts

| Chart | Description |
|-------|-------------|
| [app](charts/app) | A minimal, hardened chart for a single-pod stateless application |

## Layout

```
charts/<name>/          # one directory per chart — the path chart-releaser scans
  Chart.yaml
  values.yaml           # comments prefixed `# --` become the README values table
  values.schema.json    # rejects unknown/malformed values at install time
  README.md             # generated; edit README.md.gotmpl instead
  templates/
  ci/*-values.yaml      # each file is a separate `ct install` case
ct.yaml                 # chart-testing config
scripts/kubeconform.sh  # render + validate against real API schemas
.github/pages/          # landing page synced to the gh-pages branch
```

## Local development

```console
make check          # lint + template + docs + kubeconform (downloads tools into ./bin)
make docs           # regenerate chart READMEs after editing values.yaml
make kubeconform K8S_VERSION=1.34.0
```

`make check` covers everything CI does except the kind install, which needs a
container runtime:

```console
ct lint --config ct.yaml
ct install --config ct.yaml     # requires a running cluster
```

## Release process

1. Open a PR touching `charts/<name>/`.
2. **Bump `version:` in that chart's `Chart.yaml`.** `ct lint` fails without it,
   and chart-releaser silently skips charts whose version already has a release.
   Use semver: patch for template fixes, minor for new values, major for
   breaking value renames or removals.
3. Run `make docs` and commit the regenerated README.
4. On merge to `main`, [`release.yaml`](.github/workflows/release.yaml):
   - packages changed charts and creates a GitHub Release per chart version,
   - regenerates `index.yaml` on the `gh-pages` branch,
   - pushes the same packages to `ghcr.io/mycroft/charts` as OCI artifacts,
   - syncs the landing page.

`appVersion` tracks the upstream application; `version` tracks the chart. They
move independently.

## One-time repository setup

- **Settings → Pages → Source: "Deploy from a branch", branch `gh-pages`, `/`
  (root).** The default "GitHub Actions" source will not publish
  chart-releaser's commits, and the failure is silent.
- **Settings → Actions → General → Workflow permissions: "Read and write".**
  The release workflow needs it to push to `gh-pages` and create releases.
- The `gh-pages` branch is created automatically on the first release run.
- The first OCI push creates a private GHCR package; make it public under
  **Packages → charts/app → Package settings** if you want anonymous pulls.

## Adding a chart

Copy `charts/app`, rename the directory, update `Chart.yaml`, and reset
`version` to `0.1.0`. The workflows pick it up with no changes — they iterate
over `charts/*/`.
