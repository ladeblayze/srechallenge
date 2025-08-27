FROM python:3.12-slim AS base
ARG APP_USER=app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_NO_CACHE_DIR=1

# Install curl for uv installer + runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates tini wget \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Astral) to respect project lockfiles
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Copy only the files we know exist for better layer caching
COPY pyproject.toml ./
# Copy uv.lock if it exists
COPY uv.lock* ./

# Create virtual environment and install dependencies
RUN uv venv && . .venv/bin/activate && uv sync --frozen --no-dev

# Now add the application code
COPY . /app

# Create non-root user and data directory
RUN groupadd -r ${APP_USER} && useradd -r -g ${APP_USER} ${APP_USER} \
    && mkdir -p /data/dumbkvstore \
    && chown -R ${APP_USER}:${APP_USER} /app /data

# Default envs (overridable at runtime)
ENV DATABASE_TYPE=sqlite \
    DATABASE_LOCATION=/data/dumbkvstore/dumbkv.db

EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD \
    wget -qO- http://127.0.0.1:8000/ >/dev/null || exit 1

USER ${APP_USER}
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/app/.venv/bin/uvicorn", "main:api", "--host", "0.0.0.0", "--port", "8000", "--log-config", "logging.yaml"]