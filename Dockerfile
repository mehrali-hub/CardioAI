# ── CardioAI Dockerfile ──────────────────────────────────
# Python 3.11 slim — small, production-ready base image
FROM python:3.11-slim

# Metadata
LABEL maintainer="Astreonix"
LABEL description="CardioAI — Heart Disease Risk Prediction Platform"

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_ENV=production \
    PORT=5000

# Set working directory
WORKDIR /app

# Install system dependencies (needed for matplotlib, reportlab)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies first (layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Create directory for SQLite database (persistent volume on Render)
RUN mkdir -p /app/instance

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

# Run with gunicorn in production
CMD gunicorn --bind 0.0.0.0:$PORT \
             --workers 2 \
             --threads 2 \
             --timeout 120 \
             --log-level info \
             --access-logfile - \
             --error-logfile - \
             app:app
