# ✅ FINAL GUARANTEED DOCKERFILE (for Google Cloud Run)
FROM python:3.11-bullseye

# Prevent prompts and enable UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

# ---- Install build & image libraries ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    zlib1g-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libtiff-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libopenblas-dev \
    liblapack-dev \
    libpoppler-cpp-dev \
    ghostscript \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- Set working directory ----
WORKDIR /app
COPY . /app

# ---- Python deps ----
RUN pip install --upgrade pip setuptools wheel

# ✅ Preinstall heavy libs (skip wheel builds)
RUN pip install numpy==1.26.4 pandas==2.2.2 Pillow==10.2.0 PyMuPDF==1.24.1 streamlit==1.35.0 plotly==5.22.0 scikit-learn==1.5.0

# ---- Then install project-specific packages ----
RUN if [ -f requirements.txt ]; then pip install -r requirements.txt --no-cache-dir; fi

# ---- Expose & Run ----
EXPOSE 8080
CMD ["streamlit", "run", "app.py", "--server.port=8080", "--server.address=0.0.0.0"]
