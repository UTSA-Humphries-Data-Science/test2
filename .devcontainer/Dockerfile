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
RUN mamba install -c conda-forge -y --quiet \
    psycopg2 \
    sqlalchemy \
    plotly \
    bokeh \
    lxml \
    beautifulsoup4 \
    nodejs \
    gh \
    imagemagick \
    r-devtools \
    r-remotes && \
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

# ---- R packages: Jupyter kernel & IDE support ----
RUN R -e "install.packages(c( \
    'IRkernel', 'repr', 'IRdisplay', 'pbdZMQ', 'uuid', 'digest', \
    'languageserver', 'httpgd' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: Core tidyverse & data manipulation ----
RUN R -e "install.packages(c( \
    'tidyverse', 'dplyr', 'ggplot2', 'readr', 'tidyr', 'tibble', \
    'stringr', 'forcats', 'lubridate', 'purrr', \
    'reshape', 'reshape2', 'data.table', 'fastDummies' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: Database connectivity ----
RUN R -e "install.packages(c( \
    'DBI', 'RPostgreSQL', 'RSQLite', 'dbplyr' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: Documentation & development ----
RUN R -e "install.packages(c( \
    'knitr', 'rmarkdown', 'roxygen2', 'testthat' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: Web & data import ----
RUN R -e "install.packages(c( \
    'httr', 'jsonlite', 'rvest', 'curl' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: Module 1 - Data Exploration & Statistics ----
RUN R -e "install.packages(c( \
    'Hmisc', 'pastecs', 'psych', 'e1071', 'caret', \
    'correlation', 'broom', 'scales' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: Module 2 - ANOVA, MANOVA, ANCOVA ----
RUN R -e "install.packages(c( \
    'car', 'effectsize', 'rstatix', 'multcomp', 'ggpubr', 'AICcmodavg', \
    'MASS', 'mvnormalTest', 'heplots' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: Module 3 - PCA, PCR, MDS ----
RUN R -e "install.packages(c( \
    'corrr', 'corrplot', 'ggcorrplot', \
    'FactoMineR', 'factoextra', 'pls', \
    'cluster', 'igraph' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: Module 4 - Factor Analysis & Conjoint ----
RUN R -e "install.packages(c( \
    'GPArotation', 'nFactors', 'conjoint', \
    'lavaan', 'lavaanPlot', 'DiagrammeR' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

# ---- R packages: ML & Visualization ----
RUN R -e "install.packages(c( \
    'class', 'randomForest', 'nnet', \
    'GGally', 'gridExtra', 'ggdendro', 'ggrepel', \
    'plotly', 'RColorBrewer', 'forecast' \
  ), repos='https://cloud.r-project.org', Ncpus=4)"

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
