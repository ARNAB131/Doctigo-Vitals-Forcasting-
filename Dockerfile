# ---- Base image ----
FROM python:3.12-slim

# ---- System deps ----
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libopenblas-dev \
    liblapack-dev \
    pkg-config \
    libharfbuzz-dev \
    libfribidi-dev \
    libtiff-dev \
    libxcb1-dev \
    libpoppler-cpp-dev \
    && rm -rf /var/lib/apt/lists/*

# ---- Working directory ----
WORKDIR /app

# ---- Copy project ----
COPY . /app

# ---- Install Python deps ----
RUN pip install --upgrade pip setuptools wheel
RUN pip install -r requirements.txt

# ---- Expose port ----
EXPOSE 8080
ENV PORT=8080

# ---- Run app ----
CMD ["streamlit", "run", "app.py", "--server.port=8080", "--server.address=0.0.0.0"]
