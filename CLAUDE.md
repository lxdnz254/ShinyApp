# CLAUDE.md — AI Assistant Guide for ShinyApp

## Project Overview

This is an **R Shiny web application** for interactively demonstrating and comparing **K-means** and **Kernel K-means** clustering algorithms on non-linear 2D data. It is deployed on ShinyApps.io and accompanied by an R presentation (io2012 framework) covering the theory.

- **Live App**: https://lxdnz-254.shinyapps.io/ClusterAnalysis
- **GitHub**: https://github.com/lxdnz254/ShinyApp
- **Author**: Alex McBride

---

## Repository Structure

```
ShinyApp/
├── UI.R                        # Shiny UI definition (layout, inputs, outputs)
├── server.R                    # Shiny server logic (clustering, metrics, plots)
├── self_test.data              # 300 2D data points (X, Y) — non-linear distribution
├── self_test.ground            # Ground truth binary labels (0/1) for k=2 validation
├── www/
│   └── bootstrap.css           # Bootstrap 3 CSS for UI styling
├── Kmeans/
│   ├── index.Rmd               # R presentation source (io2012 framework)
│   ├── Index.html              # Compiled HTML slides
│   ├── Index.md                # Markdown version of slides
│   ├── .RProfile               # R environment config (SSL, RPubs upload method)
│   ├── assets/                 # Slide CSS, JS, and generated figures
│   └── libraries/              # io2012 presentation framework libraries
├── shinyapps/
│   └── lxdnz-254/
│       └── ClusterAnalysis.dcf # ShinyApps.io deployment manifest
└── README.md
```

---

## Application Architecture

### Classic Two-File Shiny Structure

| File | Role |
|------|------|
| `UI.R` | Defines layout, input widgets, and output placeholders |
| `server.R` | Reactive logic: data loading, clustering, metrics, rendering |

### Core Data Flow

```
self_test.data  →  data loading  →  compute() reactive  →  plot output
self_test.ground →  class() reactive  →  result() reactive  →  metrics output
```

### Key Reactive Functions in `server.R`

| Function | Purpose |
|----------|---------|
| `class()` | Loads ground truth labels for k=2; generates random labels otherwise |
| `compute()` | Runs `kmeans()` or `kkmeans()` (kernlab) based on user input |
| `result()` | Calculates Purity and NMI validation metrics |
| `kkmeans.ui` | Renders conditional sigma slider for Kernel K-means only |

### R Packages Used

| Package | Purpose |
|---------|---------|
| `shiny` | Web application framework |
| `ggplot2` | Cluster visualization |
| `kernlab` | Kernel K-means (`kkmeans()`) with RBF kernel |
| `fpc` | Flexible procedures for clustering |
| `cluster` | Cluster analysis utilities |
| `clue` | Cluster evaluation (NMI) |

---

## Data Files

### `self_test.data`
- 300 observations, 2 features (space-separated)
- Columns renamed to `x` and `y` on load
- Non-linear distribution (suitable for demonstrating kernel advantage over linear K-means)
- X range: approximately -10.99 to 14.66; Y range: approximately -10.27 to 13.81

### `self_test.ground`
- 300 binary labels (0 or 1), one per line
- Used as ground truth when `k=2` for Purity and NMI validation
- When `k > 2`, random labels are generated as a placeholder

---

## UI Structure (`UI.R`)

```
fluidPage (Bootstrap CSS theme)
└── titlePanel: "Cluster Analysis: K-means versus Kernel K-means"
└── plotOutput: "plot"
└── tabsetPanel
    ├── Tab: Instructions — overview text and GitHub link
    └── Tab: Input Selection
        ├── selectInput: "kernel" (K-means | RBF/Kernel K-means)
        ├── sliderInput: "clusters" (2–8)
        ├── uiOutput: "sigma_ui" (conditional — shown only for Kernel K-means)
        ├── verbatimTextOutput: "purity"
        └── verbatimTextOutput: "NMI"
```

---

## Key Conventions

### R/Shiny Patterns
- **Reactive functions** (`reactive({})`) are used for `class`, `compute`, and `result` — always call them as functions (e.g., `compute()`, not `compute`)
- **Conditional UI** is rendered via `renderUI()` in server and `uiOutput()` in UI — used for the sigma slider
- **Reproducibility**: `set.seed(12345)` is set before clustering in `server.R`
- **Column naming**: After reading `self_test.data`, columns are renamed to lowercase `x` and `y`

### Plot Style
- Uses `ggplot2` with `geom_point()` for data; cluster centers use `pch = 17` (triangles)
- Color aesthetic (`aes(color = ...)`) maps cluster assignments
- Plot background is transparent (white/blank theme)

### Validation Metrics
- **Purity**: Fraction of correctly assigned points in the dominant class per cluster
- **NMI (Normalized Mutual Information)**: Measures agreement between cluster labels and ground truth
- Both metrics only use ground truth when `k=2`

---

## Development Workflow

### Running Locally
Open `UI.R` or `server.R` in RStudio and click **Run App**, or from R console:
```r
library(shiny)
runApp("/home/user/ShinyApp")
```

### Required R Packages
Install all dependencies before running:
```r
install.packages(c("shiny", "ggplot2", "fpc", "cluster", "clue", "kernlab"))
```

### Updating the Presentation
Edit `Kmeans/index.Rmd` and re-knit using `slidify` or RStudio's Knit button to regenerate `Index.html` and `Index.md`.

### Deployment to ShinyApps.io

Deployment is automated via GitHub Actions (`.github/workflows/deploy.yml`). Every push to `master` triggers a deploy to shinyapps.io automatically.

For manual deployment from R:
```r
library(rsconnect)
rsconnect::deployApp("/home/user/ShinyApp", appName = "ClusterAnalysis")
```
The deployment manifest is at `shinyapps/lxdnz-254/ClusterAnalysis.dcf`.

---

## CI/CD — Required Manual Setup (One-Time)

Before the GitHub Actions deploy workflow will function, three secrets must be added to the GitHub repository:

| Secret Name | Where to Find It |
|-------------|-----------------|
| `SHINYAPPS_ACCOUNT` | Your shinyapps.io username (e.g. `lxdnz-254`) |
| `SHINYAPPS_TOKEN` | shinyapps.io dashboard → Account → Tokens → Show |
| `SHINYAPPS_SECRET` | shinyapps.io dashboard → Account → Tokens → Show |

**Steps to add secrets:**
1. Go to https://github.com/lxdnz254/ShinyApp/settings/secrets/actions
2. Click **New repository secret** for each of the three secrets above
3. Push any commit to `master` to verify the workflow runs successfully

**To retrieve shinyapps.io token and secret:**
1. Log in to https://www.shinyapps.io
2. Go to **Account → Tokens**
3. Click **Show** next to your token to reveal both the token and secret values

Once secrets are in place, all future merges to `master` will auto-deploy without any manual steps.

---

## Planned Data Display Improvements

The following improvements are prioritised by impact on data display, which is the primary development goal.

### High Priority

| Improvement | Description | Files to Change |
|-------------|-------------|-----------------|
| **Styled metric boxes** | Replace raw `verbatimTextOutput` for Purity/NMI with formatted value boxes using `shinydashboard` or inline HTML/CSS | `UI.R`, `server.R` |
| **Per-cluster summary table** | Show cluster size, centroid coordinates, and within-cluster variance per cluster using `DT::datatable()` | `UI.R`, `server.R` |
| **Side-by-side comparison plot** | Render K-means and Kernel K-means plots simultaneously so differences are immediately visible without toggling | `UI.R`, `server.R` |

### Medium Priority

| Improvement | Description | Files to Change |
|-------------|-------------|-----------------|
| **Elbow/scree plot** | Plot within-cluster sum of squares vs. k to help users identify the optimal cluster count | `UI.R`, `server.R` |
| **Metrics history table** | Accumulate Purity and NMI across user interactions so results across different k/sigma settings can be compared | `server.R` |
| **Data table tab** | Add a `DT` tab showing each point's X, Y, assigned cluster, and ground truth match (when k=2) | `UI.R`, `server.R` |

### Lower Priority

| Improvement | Description | Files to Change |
|-------------|-------------|-----------------|
| Selectable datasets | Allow users to upload or choose from built-in datasets | `UI.R`, `server.R` |
| Additional algorithms | DBSCAN, Gaussian Mixture Models | `server.R` |
| Additional kernel types | Beyond RBF | `UI.R`, `server.R` |

### Additional R Packages Required

```r
install.packages(c("DT"))  # for datatable outputs
```

---

## Future Development (from original README and slides)

- Support for selectable datasets beyond the default `self_test.data`
- Additional clustering algorithms (e.g., DBSCAN, Gaussian Mixture Models)
- Additional kernel types beyond RBF
- Configurable plot aesthetics
- Formal unit testing with `testthat`

---

## No-Test Environment Note

There is no automated test suite. Validation is performed within the app itself using Purity and NMI metrics against the `self_test.ground` labels. When adding new features, manually verify that:
1. The app launches without errors
2. Switching between K-means and Kernel K-means works correctly
3. The sigma slider appears/disappears based on kernel selection
4. Cluster counts 2–8 all render without errors
