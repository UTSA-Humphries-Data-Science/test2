FROM quay.io/jupyter/datascience-notebook:latest

# ============================================================
# SYSTEM PACKAGES (as root)
# ============================================================
USER root

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  libnlopt-dev \
  cmake \
  postgresql \
  postgresql-contrib && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Passwordless sudo for jovyan (classroom use)
RUN echo 'jovyan ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jovyan && \
  chmod 0440 /etc/sudoers.d/jovyan

# Configure PostgreSQL for trust auth (no passwords for classroom)
RUN echo "local all all trust" > /etc/postgresql/*/main/pg_hba.conf && \
  echo "host all all 127.0.0.1/32 trust" >> /etc/postgresql/*/main/pg_hba.conf && \
  echo "host all all ::1/128 trust" >> /etc/postgresql/*/main/pg_hba.conf

RUN chown -R jovyan:users /home/jovyan

# ============================================================
# ALL INSTALLS AS JOVYAN (no root needed after this)
# ============================================================
USER jovyan

# ---- Conda packages (binary, fast) ----
# Install as many R packages as possible via mamba (pre-compiled, instant)
RUN mamba install -c conda-forge -y --quiet \
  psycopg2 sqlalchemy plotly bokeh lxml beautifulsoup4 nodejs gh imagemagick \
  r-devtools r-remotes r-irkernel r-languageserver \
  r-tidyverse r-dplyr r-ggplot2 r-readr r-tidyr r-tibble \
  r-stringr r-forcats r-lubridate r-purrr \
  r-reshape2 r-data.table \
  r-dbi r-rsqlite r-dbplyr \
  r-knitr r-rmarkdown r-testthat \
  r-httr r-jsonlite r-rvest r-curl \
  r-hmisc r-psych r-e1071 r-caret r-broom r-scales \
  r-car r-mass r-multcomp r-ggpubr \
  r-corrplot r-factominer r-factoextra r-pls r-cluster r-igraph \
  r-gparotation r-lavaan r-diagrammer \
  r-class r-randomforest r-nnet \
  r-ggally r-gridextra r-ggrepel r-plotly r-rcolorbrewer r-forecast && \
  mamba clean --all -f -y

# ---- Python packages (data science essentials) ----
RUN pip install --no-cache-dir \
  debugpy ipykernel \
  openpyxl xlrd xlsxwriter \
  statsmodels \
  ipython-sql \
  streamlit fastapi requests \
  pytest pytest-cov \
  black flake8 autopep8

# ---- R packages: Only packages NOT available in conda ----
RUN R -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest')); \
  install.packages(c( \
  'httpgd', 'repr', 'IRdisplay', 'pbdZMQ', 'uuid', 'digest', \
  'reshape', 'fastDummies', 'RPostgreSQL', 'roxygen2', \
  'pastecs', 'correlation', \
  'effectsize', 'rstatix', 'AICcmodavg', 'mvnormalTest', 'heplots', \
  'corrr', 'ggcorrplot', \
  'nFactors', 'conjoint', 'lavaanPlot', \
  'ggdendro' \
  ), Ncpus=8)"

# ---- R packages: GitHub-only ----
RUN R -e "devtools::install_github('gedeck/mlba/mlba', force=TRUE, upgrade='never')" && \
  R -e "devtools::install_github('gastonstat/DiscriMiner', force=TRUE, upgrade='never')"

# ---- Register Jupyter kernels globally ----
RUN R -e "IRkernel::installspec(user=FALSE)" && \
  python3 -m ipykernel install --name python3 --display-name "Python 3" --user

# ---- Jupyter config (no token/password for classroom) ----
RUN mkdir -p /home/jovyan/.jupyter && \
  echo "c.ServerApp.token = ''" > /home/jovyan/.jupyter/jupyter_server_config.py && \
  echo "c.ServerApp.password = ''" >> /home/jovyan/.jupyter/jupyter_server_config.py && \
  echo "c.ServerApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_server_config.py && \
  echo "c.ServerApp.ip = '0.0.0.0'" >> /home/jovyan/.jupyter/jupyter_server_config.py && \
  echo "c.ServerApp.allow_origin = '*'" >> /home/jovyan/.jupyter/jupyter_server_config.py && \
  echo "c.ServerApp.disable_check_xsrf = True" >> /home/jovyan/.jupyter/jupyter_server_config.py

# ---- R profile (user library + CRAN mirror) ----
RUN mkdir -p /home/jovyan/R/library && \
  echo 'user_lib <- "~/R/library"' > /home/jovyan/.Rprofile && \
  echo 'if (!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)' >> /home/jovyan/.Rprofile && \
  echo '.libPaths(c(user_lib, .libPaths()))' >> /home/jovyan/.Rprofile && \
  echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"))' >> /home/jovyan/.Rprofile && \
  echo 'options(Ncpus = 2)' >> /home/jovyan/.Rprofile
