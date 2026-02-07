FROM quay.io/jupyter/datascience-notebook:latest

# Switch to root to install system packages
USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libnlopt-dev \
        cmake \
        postgresql \
        postgresql-contrib && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure passwordless sudo for jovyan
RUN echo 'jovyan ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jovyan && \
    chmod 0440 /etc/sudoers.d/jovyan

# Ensure proper ownership
RUN chown -R jovyan:users /home/jovyan

# Switch back to jovyan user
USER jovyan

# ============================================================
# BAKE IN: Python debugging support
# ============================================================
RUN pip install --no-cache-dir debugpy ipykernel

# ============================================================
# BAKE IN: R packages for coursework + debugging/LSP
# ============================================================
RUN R -e "install.packages(c( \
    'languageserver', \
    'httpgd', \
    'IRkernel', \
    'devtools', \
    'tidyverse', \
    'Hmisc', \
    'psych', \
    'pastecs', \
    'caret', \
    'fastDummies', \
    'e1071', \
    'corrplot', \
    'ggcorrplot', \
    'randomForest' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# Install mlba from GitHub
RUN R -e "devtools::install_github('gedeck/mlba/mlba', force=TRUE)"

# Register R kernel globally for Jupyter
RUN R -e "IRkernel::installspec(user=FALSE)"

# Ensure Python kernel is registered
RUN python3 -m ipykernel install --name python3 --display-name "Python 3" --user
