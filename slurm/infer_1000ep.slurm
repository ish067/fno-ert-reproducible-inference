#!/bin/bash
#SBATCH -J fno-infer-1000
#SBATCH -A coc
#SBATCH -q coc-ice
#SBATCH -N 1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH -t 00:15:00
#SBATCH -o logs/infer1000_%j.out
#SBATCH -e logs/infer1000_%j.err

cd $SLURM_SUBMIT_DIR
PY=${FNO_ENV:-$HOME/scratch/envs/fno-ert}/bin/python
nvidia-smi
echo "===== SMOKE TEST ====="; $PY -u scripts/smoke_test.py --ckpt outputs/fno_ert_1000ep.pt
echo "===== INFERENCE =====";  $PY -u scripts/infer.py --ckpt outputs/fno_ert_1000ep.pt
echo "===== VALIDATION =====";  $PY -u scripts/validate.py --ckpt outputs/fno_ert_1000ep.pt
