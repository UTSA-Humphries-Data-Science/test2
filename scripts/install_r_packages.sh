#!/bin/bash

echo "🔧 Installing Essential R Data Science Packages"
echo "This script ensures all required packages are installed for data science work"

# Run R script to install all essential packages
R --no-save --no-restore << 'EOF'
# Set up user library
user_lib <- "~/R/library"
if (!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)
.libPaths(c(user_lib, .libPaths()))

# Complete list of essential packages
essential_packages <- c(
    # Jupyter/IRkernel
    "IRkernel", "repr", "uuid", "digest", "IRdisplay", "pbdZMQ",
    
    # Core tidyverse
    "dplyr", "ggplot2", "readr", "tidyr", "tibble", "stringr", "forcats", "lubridate",
    
    # Database
    "DBI", "RPostgreSQL", "RSQLite", "dbplyr",
    
    # Development and documentation
    "devtools", "knitr", "rmarkdown", "roxygen2", "testthat",
    
    # Web and data import
    "httr", "jsonlite", "rvest", "curl",
    
    # Statistical and visualization
    "broom", "scales", "plotly", "RColorBrewer", "ggdendro", "GGally",
    
    # Data manipulation
    "reshape", "reshape2", "data.table", "fastDummies",
    
    # Module 1: Data Exploration and Statistics
    "Hmisc",      # High-level graphics, describe(), data analysis utilities
    "pastecs",    # Space-time series, stat.desc() for detailed statistics
    "psych",      # Psychological research tools, describe() with skewness/kurtosis
    "e1071",      # SVMs, skewness/kurtosis functions, naive Bayes
    "correlation", # Correlation analysis with multiple methods
    
    # Module 2: ANOVA, MANOVA, ANCOVA
    "ggpubr",      # Publication-ready plots, customizing ggplot2
    "tidyverse",   # Data manipulation suite (includes dplyr, ggplot2, etc.)
    "AICcmodavg",  # Model comparison (AIC, BIC, likelihood)
    "gridExtra",   # Arrange multiple plots
    "effectsize",  # Effect size calculations (eta squared, etc.)
    "MASS",        # LDA, discriminant analysis, modern applied statistics
    "rstatix",     # Pipe-friendly statistical tests
    "mvnormalTest", # Multivariate normality tests (Mardia's test)
    "heplots",     # Box's M test for homogeneity of covariance
    "car",         # Companion to Applied Regression (Levene's test, Type III SS)
    "multcomp",    # Post-hoc comparisons (glht, Tukey)
    
    # Module 3: PCA, PCR, MDS
    "corrr",       # Correlation analysis and data frame handling
    "ggcorrplot",  # Visualization of correlation matrices
    "FactoMineR",  # Exploratory data analysis including PCA
    "factoextra",  # Visualization of PCA outputs (scree plot, biplot)
    "pls",         # Partial Least Squares and Principal Component Regression
    "igraph",      # Network analysis and graph-based MDS visualization
    "cluster",     # Clustering algorithms and MDS support
    
    # Module 4: Factor Analysis and Conjoint Analysis
    "corrplot",    # Correlation matrix visualization (ellipse, color plots)
    "GPArotation", # Gradient Projection Algorithm for factor rotation
    "nFactors",    # Determining number of factors (parallel analysis)
    "conjoint",    # Conjoint analysis (part-worth utilities, importance)
    "lavaan",      # Latent Variable Analysis - SEM, CFA, path analysis
    "lavaanPlot",  # Visualization of SEM path diagrams
    "DiagrammeR"   # Graph/diagram rendering for SEM plots
)

cat("Installing", length(essential_packages), "essential packages...\n")

# Install missing packages
installed_count <- 0
failed_packages <- c()

for (pkg in essential_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        cat("Installing", pkg, "...\n")
        tryCatch({
            install.packages(pkg, lib = user_lib, repos = "https://cloud.r-project.org/", quiet = TRUE)
            if (requireNamespace(pkg, quietly = TRUE)) {
                installed_count <- installed_count + 1
                cat("✅", pkg, "installed successfully\n")
            } else {
                failed_packages <- c(failed_packages, pkg)
                cat("❌", pkg, "installation verification failed\n")
            }
        }, error = function(e) {
            failed_packages <- c(failed_packages, pkg)
            cat("❌", pkg, "installation failed:", conditionMessage(e), "\n")
        })
    } else {
        cat("✅", pkg, "already available\n")
    }
}

# Summary
cat("\n📊 Installation Summary:\n")
cat("Total packages checked:", length(essential_packages), "\n")
cat("Newly installed:", installed_count, "\n")
cat("Failed installations:", length(failed_packages), "\n")

if (length(failed_packages) > 0) {
    cat("Failed packages:", toString(failed_packages), "\n")
}

# Register R kernel
if (requireNamespace("IRkernel", quietly = TRUE)) {
    IRkernel::installspec(user = TRUE)
    cat("✅ R kernel registered with Jupyter\n")
}

cat("🎉 R package installation complete!\n")

# Install packages from GitHub (not available on CRAN)
cat("\n📦 Installing packages from GitHub...\n")
if (requireNamespace("devtools", quietly = TRUE)) {
    devtools::install_github("gastonstat/DiscriMiner")
    cat("✅ DiscriMiner installed from GitHub\n")
} else {
    cat("⚠️ devtools not available, skipping GitHub packages\n")
}
EOF

echo "✅ R data science packages setup completed"
