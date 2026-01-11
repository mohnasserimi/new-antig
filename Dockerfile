
FROM python:3.10-slim

# 1. Install System Dependencies (FFmpeg & Curl for Deno)
RUN apt-get update && \
    apt-get install -y ffmpeg curl unzip && \
    rm -rf /var/lib/apt/lists/*

# 2. Install Deno
# Hugging Face usually provides a user with ID 1000. We will install Deno globally or for that user.
# Here we install to a common location and add to PATH.
ENV DENO_INSTALL=/usr/local
RUN curl -fsSL https://deno.land/x/install/install.sh | sh

# 3. Set up a working directory
WORKDIR /app

# 4. Create a non-root user
RUN useradd -m -u 1000 user

# 5. Copy ALL project files (includes youtube_cookies.txt and any other needed files)
COPY --chown=user:user . .

# 6. Ensure the downloads folder exists with correct permissions
RUN mkdir -p /app/downloads && chown -R user:user /app

# 6. Switch to non-root user
USER user

# 7. Install Python Requirements
ENV PATH="/home/user/.local/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -U -r requirements.txt "yt-dlp[default]" --pre

# 8. Environment Variables
# Render/HuggingFace will set PORT automatically, but we expose common ports
ENV PYTHONUNBUFFERED=1

# 9. Expose ports (Render uses dynamic PORT, HuggingFace uses 7860)
EXPOSE 5000 7860

# 10. Run the application
CMD ["python", "app.py"]
