#!/bin/bash
#SBATCH -J fno-train-1000
#SBATCH -A coc
#SBATCH -q coc-ice
#SBATCH -N 1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH -t 00:45:00
#SBATCH -o logs/train1000_%j.out
#SBATCH -e logs/train1000_%j.err

cd $SLURM_SUBMIT_DIR
PY=${FNO_ENV:-$HOME/scratch/envs/fno-ert}/bin/python
nvidia-smi
$PY -u scripts/train.py --config configs/fno_ert_1000ep.yaml --out outputs/fno_ert_1000ep.pt
