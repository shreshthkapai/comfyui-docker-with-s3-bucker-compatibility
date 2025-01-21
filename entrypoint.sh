#!/bin/bash

if [ -f "/app/custom_workflow.json" ]; then
    echo "Setting up custom workflow..."
    mkdir -p /app/web/workflows
    cp /app/custom_workflow.json /app/web/workflows/default.json
fi

install_manager() {
    echo "ComfyUI Manager not found. Installing..."
    cd /app/custom_nodes
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git comfyui-manager
    cd /app
}

install_segment_anything() {
    echo "Segment Anything not found. Installing..."
    cd /app/custom_nodes
    git clone https://github.com/storyicon/comfyui_segment_anything.git
    cd comfyui_segment_anything
    pip install -r requirements.txt
    cd /app
}

install_Florence2SAM2() {
    echo "Florence2SAM2 not found. Installing..."
    cd /app/custom_nodes
    git clone https://github.com/rdancer/ComfyUI_Florence2SAM2.git
    cd ComfyUI_Florence2SAM2
    pip install -r requirements.txt
    cd /app
}

# Check and install custom nodes if needed
if [ ! -d "/app/custom_nodes/comfyui-manager" ]; then
    install_manager
fi

if [ ! -d "/app/custom_nodes/comfyui_segment_anything" ]; then
    install_segment_anything
fi

if [ ! -d "/app/custom_nodes/ComfyUI_Florence2SAM2" ]; then
    install_Florence2SAM2
fi

# Start ComfyUI
exec python3 main.py --listen 0.0.0.0 --port 8188