
  
# ══════════════════════════════════════════════════════ 
# STAGE 1: BUILDER 
# Purpose: Install build tools and compile dependencies 
# This stage will NOT appear in the final image 
# ══════════════════════════════════════════════════════ 
FROM python:3.11-slim AS builder 
  
# Install system build tools needed to compile some Python packages 
# --no-install-recommends: don't install optional packages (smaller image) 
# rm -rf /var/lib/apt/lists/*: delete apt cache after installing 
RUN apt-get update && apt-get install -y --no-install-recommends \ 
    build-essential \ 
    curl \ 
    git \ 
    && rm -rf /var/lib/apt/lists/* 
  
# Install Poetry (the same way we did on our laptops) 
ENV POETRY_HOME=/opt/poetry \ 
    POETRY_VIRTUALENVS_IN_PROJECT=true \ 
    POETRY_NO_INTERACTION=1 \ 
    POETRY_VERSION=2.3.4
  
RUN curl -sSL https://install.python-poetry.org | python3 - 
ENV PATH="/opt/poetry/bin:$PATH" 
  
# Set working directory inside the builder stage 
WORKDIR /app 
  
# Copy ONLY the dependency files first 
# Why: Docker caches each layer. If only your code changes (not dependencies), 
#      Docker will reuse the cached 'poetry install' layer — much faster! 
COPY pyproject.toml poetry.lock ./ 
  
# Install ONLY production dependencies (no pytest, black, etc.) 
RUN poetry install --only=main --no-root 
  
# ══════════════════════════════════════════════════════ 
# STAGE 2: RUNTIME 
# Purpose: Lean, production-ready image 
# This is what gets deployed 
# ══════════════════════════════════════════════════════ 
FROM python:3.11-slim AS runtime 
  
# Security: create a non-root user 
# Running as root inside containers is a security risk 
RUN useradd --create-home --shell /bin/bash appuser 
  
# Install curl for the HEALTHCHECK command only 
RUN apt-get update && apt-get install -y --no-install-recommends curl \ 
    && rm -rf /var/lib/apt/lists/*