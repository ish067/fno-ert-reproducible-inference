#!/bin/bash
#SBATCH -J gpu-check
#SBATCH -A coc
#SBATCH -q coc-ice
#SBATCH -N 1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH -t 00:10:00
#SBATCH -o logs/gpu_check_%j.out
#SBATCH -e logs/gpu_check_%j.err

cd $SLURM_SUBMIT_DIR
module purge
module load anaconda3
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate /storage/ice1/0/5/ityagi8/envs/fno-ert
nvidia-smi
python -c "import torch, neuralop; print(torch.__version__, torch.cuda.is_available(), neuralop.__version__)"
