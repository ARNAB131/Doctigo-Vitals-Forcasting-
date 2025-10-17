# ✅ Ultra-stable Dockerfile for Doctigo Vitals Forecasting (GCP Safe)
FROM python:3.11-slim

# Set environment
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Install core system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    libfreetype6-dev \
    libopenblas-dev \
    liblapack-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    libpoppler-cpp-dev \
    ghostscript \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Upgrade pip and preinstall core packages
RUN pip install --upgrade pip setuptools wheel

# Install dependencies safely
RUN pip install pandas==2.2.2 numpy==1.26.4 Pillow==10.2.0 PyMuPDF==1.24.1 streamlit==1.35.0 plotly==5.22.0 scikit-learn==1.5.0

# Install remaining dependencies
RUN if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# Expose default Streamlit port
EXPOSE 8080
ENV PORT=8080

# Run the Streamlit app
CMD ["streamlit", "run", "app.py", "--server.port=8080", "--server.address=0.0.0.0"]
