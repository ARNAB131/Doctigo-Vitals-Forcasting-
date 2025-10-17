# ✅ Final Google Cloud Build–Safe Dockerfile
FROM python:3.12-bullseye

# Install all required system-level dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    zlib1g-dev \
    libjpeg-dev \
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

RUN pip install --upgrade pip setuptools wheel
RUN pip install -r requirements.txt

EXPOSE 8080
ENV PORT=8080

CMD ["streamlit", "run", "app.py", "--server.port=8080", "--server.address=0.0.0.0"]