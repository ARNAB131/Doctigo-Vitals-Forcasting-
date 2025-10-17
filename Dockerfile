# -------------------------------
# Doctigo Vitals — Google Cloud Build Safe Dockerfile
# -------------------------------
FROM python:3.12-bullseye

# Install system-level build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libopenblas-dev \
    liblapack-dev \
    libtiff-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    libpoppler-cpp-dev \
    libmupdf-dev \
    libmupdf-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

# Upgrade pip and install dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install pandas numpy PyMuPDF pillow plotly streamlit scikit-learn

# Expose Streamlit port
EXPOSE 8080
ENV PORT=8080

# Run Streamlit app
CMD ["streamlit", "run", "app.py", "--server.port=8080", "--server.address=0.0.0.0"]
