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
