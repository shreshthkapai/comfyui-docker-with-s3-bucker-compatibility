FROM amazonlinux:2023

# Set up working directory
WORKDIR /app

# Install required system packages
RUN dnf update -y && dnf install -y \
    git \
    python3 \
    python3-pip \
    mesa-libGL \
    glib2 \
    gcc \
    make \
    python3-devel \
    && dnf clean all

# Configure git
RUN git config --global http.sslVerify false && \
    git config --global http.postBuffer 1048576000

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Install PyTorch with CUDA support
RUN pip3 install --no-cache-dir torch==2.5.1+cu121 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Create required directories
RUN mkdir -p /app/models /app/output /app/custom_nodes /app/custom_nodes/comfyui_s3_save

# Install ComfyUI's requirements
RUN pip3 install --no-cache-dir -r requirements.txt

# Install AWS SDK and other dependencies
RUN pip3 install --no-cache-dir boto3 pillow

# Install custom nodes
RUN cd /app/custom_nodes && \
    git clone https://github.com/storyicon/comfyui_segment_anything.git && \
    cd comfyui_segment_anything && \
    pip3 install --no-cache-dir -r requirements.txt

RUN cd /app/custom_nodes && \
    git clone https://github.com/rdancer/ComfyUI_Florence2SAM2.git && \
    cd ComfyUI_Florence2SAM2 && \
    pip3 install --no-cache-dir iopath==0.1.10 && \
    pip3 install --no-cache-dir -r requirements.txt || \
    (echo "Attempting alternative installation method..." && \
    pip3 install --no-cache-dir --no-dependencies -r requirements.txt && \
    pip3 install --no-cache-dir samv2 --no-dependencies)

# Copy workflows and entrypoint
COPY workflows/final_masking_workflow.json /app/custom_workflow.json
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose port
EXPOSE 8188

# Set PyTorch memory settings
ENV PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]