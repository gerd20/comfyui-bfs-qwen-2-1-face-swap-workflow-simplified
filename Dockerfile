# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.10.0-base

# build-time tokens for gated downloads are read from BuildKit secret
# mounts — they are never written to a layer or to image history.
# pass via: docker buildx build --secret id=hf_token,env=HF_TOKEN .

# install custom nodes into comfyui
RUN git clone https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/ComfyUI-KJNodes && cd /comfyui/custom_nodes/ComfyUI-KJNodes && (git checkout 60cd6bc1870db94c6eeb05fbe455147a8e91c4e9 2>/dev/null || (git fetch origin 60cd6bc1870db94c6eeb05fbe455147a8e91c4e9 --depth=1 && git checkout 60cd6bc1870db94c6eeb05fbe455147a8e91c4e9) || echo "WARN: commit 60cd6bc1870db94c6eeb05fbe455147a8e91c4e9 unreachable in https://github.com/kijai/ComfyUI-KJNodes, falling back to default branch HEAD")

# download models into comfyui
RUN --mount=type=secret,id=hf_token BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || true)" comfy model download --url 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/vae/qwen_image_2.1_vae_bf16.safetensors' --relative-path models/vae --filename 'qwen_image_2.1_vae_bf16.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN --mount=type=secret,id=hf_token BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || true)" comfy model download --url 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/text_encoders/qwen3vl_8b_int8_convrot.safetensors' --relative-path models/text_encoders --filename 'qwen3vl_8b_int8_convrot.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN --mount=type=secret,id=hf_token BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || true)" comfy model download --url 'https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/resolve/main/bfs_head_v1.1_qwen_2.1.safetensors' --relative-path models/loras --filename 'bfs_head_v1.1_qwen_2.1.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN --mount=type=secret,id=hf_token BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || true)" comfy model download --url 'https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/diffusion_models/qwen_image_2.1_int8_convrot.safetensors' --relative-path models/diffusion_models --filename 'qwen_image_2.1_int8_convrot.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN --mount=type=secret,id=hf_token BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN="$(cat /run/secrets/hf_token 2>/dev/null || true)" comfy model download --url 'https://huggingface.co/PrunaAI/Pruna-Qwen-Image-2.1/resolve/main/p_qwen_image_2.1_8step_v0.1.safetensors' --relative-path models/loras --filename 'p_qwen_image_2.1_8step_v0.1.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/IMG_5110.jpg' "https://cool-anteater-319.convex.cloud/api/storage/1f63d8be-76a7-4fc3-93d5-77af1a2c7a65"
RUN wget --progress=dot:giga -O '/comfyui/input/13213896_110_9513.jpg' "https://cool-anteater-319.convex.cloud/api/storage/da7d985f-2e8c-45c6-a25f-31cba1b52617"
