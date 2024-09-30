#!/bin/bash

MODELNAME="flan-t5"
BASEDIR="/data"

# if model doesn't exist, fetch and convert it.
if [ ! -f "$BASEDIR/models/$MODELNAME.gguf" ]; then
  echo "INFO: Downloading and converting model, this may take a while..."
  # install requirements
  apt update && apt install -y git python3 python3-pip
  python3 -m pip install huggingface_hub
  # download model
  python3 -c 'from huggingface_hub import snapshot_download; snapshot_download(repo_id="google/flan-t5-base", local_dir="$MODELNAME", local_dir_use_symlinks=False, revision="main")'
  # convert model
  python3 /app/convert_hf_to_gguf.py flan-t5 --outfile "$BASEDIR/models/$MODELNAME.gguf" --outtype q8_0
  # cleanup
  rm -rf flan-t5
fi

# run server
/app/llama-server --port 8081 --host 0.0.0.0 -m "$BASEDIR/models/$MODELNAME.gguf"