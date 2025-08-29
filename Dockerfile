FROM ubuntu:24.10

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends build-essential git && rm -rf /var/lib/apt/lists/*

RUN uv python install 3.12

# Install Python 3.12 via Ubuntu packages instead of uv
RUN apt-get update && apt-get install -y --no-install-recommends python3.12 python3.12-venv python3.12-dev curl && rm -rf /var/lib/apt/lists/*

# Set python3.12 as default python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Copy dependency files first for better caching  
COPY pyproject.toml uv.lock ./

# Install dependencies using uv but with system Python
RUN uv sync --frozen --no-dev --python /usr/bin/python3.12

# Copy application code
COPY . .

# Create directory for database
RUN mkdir -p /data/dumbkvstore

# Expose port
EXPOSE 8000

# Set environment variables
ENV DATABASE_LOCATION=/data/dumbkvstore/dumbkv.db
ENV DATABASE_TYPE=sqlite

# Health check  
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run with uv
CMD ["uv", "run", "uvicorn", "main:api", "--host", "0.0.0.0", "--port", "8000", "--log-config", "logging.yaml"]