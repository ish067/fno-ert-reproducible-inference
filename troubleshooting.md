# Troubleshooting

Every problem hit while building and verifying this workflow, with symptom, cause, and fix. Logs for the Slurm-related
ones are in `logs/`.

## 1. Data files are 133 bytes (Git LFS pointers)
- **Symptom:** after `git clone https://github.com/Hghadjari/FNO_ERT.git`, `data/evalV.mat` and `data/testV.mat` are 133
  bytes and `cat` shows `version https://git-lfs.github.com/spec/v1`, an `oid sha256:` line, and a `size` line.
- **Cause:** the files are stored with Git LFS and the clone only fetched pointer stubs. `git lfs pull` (also after
  `git lfs install`) printed nothing and downloaded nothing on the cluster.
- **Fix:** download directly from the LFS media endpoint with `curl -L -o <file> https://media.githubusercontent.com/media/Hghadjari/FNO_ERT/main/data/<file>`
  and verify with `sha256sum`; the hashes must equal the pointer `oid` values (`docs/data_checksums.txt`).

## 2. `conda activate` fails inside Slurm jobs
- **Symptom 1:** `CondaError: Run 'conda init' before 'conda deactivate'` in the job's `.err` (job 6119434), when the job was
  submitted from a shell that already had the environment active.
- **Symptom 2:** after adding `module purge`, `conda: command not found` in the `.err` (job 6119564). That job still printed
  the right answer only because the submitting shell's PATH leaked into it.
- **Fix:** do not activate conda in job scripts. Call the environment's interpreter directly
  (`$FNO_ENV/bin/python`). Job 6119696 ran from a deactivated shell with a clean `.err`.

## 3. `fatal: Unable to create '.git/index.lock': File exists`
- **Cause:** a git command was interrupted when the terminal window was closed.
- **Fix:** check nothing is running with `ps -u $USER -o pid,etime,cmd | grep '[g]it'`; if empty, `rm -f .git/index.lock`.

## 4. `git push` says "Password authentication is not supported"
- **Fix:** create a GitHub personal access token (Settings, Developer settings, Personal access tokens, Tokens (classic),
  `repo` scope) and use it as the password. The `gnome-ssh-askpass ... cannot open display` warning is harmless.
  Never put the token in a file in the repo.

## 5. Pasted code arrives corrupted
- **Symptom:** long `cat > file << 'EOF'` pastes into an SSH window interleaved with later commands, producing files with
  missing or mixed-in lines (a stray `EOF.exit(...)` line, text from the `py_compile` command inside `infer.py`).
- **Fix:** after creating any script run `wc -l` and `python -m py_compile <file>` as separate commands, or upload files
  through the GitHub web interface and `git pull` on the cluster.

## 6. Log looks cut off
- **Cause:** reading `logs/*.out` while the job is still running (job 6284517 first showed only the smoke-test header).
- **Fix:** wait until `squeue -u $USER` is empty, then read the log.

## 7. SSH session dropped while waiting
- **Symptom:** `client_loop: send disconnect: Connection reset`; the next commands ran on the local computer.
- **Effect:** none on the jobs. `sbatch` jobs keep running on the cluster. Log back in and check `squeue -u $USER`.
- **Tip:** `ssh -o ServerAliveInterval=60 <user>@login-ice.pace.gatech.edu`.

## 8. First forward pass takes about 22 s
- One-time CUDA and FFT plan initialization on the first GPU call (smoke test). `infer.py` warms up first and reports
  steady-state timing (about 1.5 ms per single sample). Do not read the first-call time as speed.

## 9. `ModuleNotFoundError: No module named 'fno_demo_min'` after editing only configs and Slurm files
- **Reported by a peer reviewer.** `infer.py`, `smoke_test.py`, and `validate.py` originally read the data/code paths from
  the config saved inside the checkpoint, which contained the author's absolute paths, so editing `configs/*.yaml`
  and `slurm/*.slurm` was not enough.
- **Fix:** the scripts now call `resolve_cfg()` (in `scripts/common.py`), which ignores paths stored in checkpoints and
  builds them from the `FNO_ERT_DIR` environment variable (default `../FNO_ERT`, next to this repo). Job scripts build
  the Python path from `FNO_ENV` (default `$HOME/scratch/envs/fno-ert`). Neither needs editing in the default layout.

## 10. Home directory full / missing libraries
- **Reported by a peer reviewer.** The home directory on ICE is only 30 GB; installing PyTorch there fills it up. Put the
  repo, environment, and data under `$HOME/scratch` (a link to the large scratch space), as in the README.

## 11. `pip install -r requirements.txt` fails or leaks personal paths
- A `pip freeze` taken after `pip install -e .` includes an editable-install line for the `neuraloperator` clone, and
  `conda env export` writes a `prefix:` line with the author's path. Both were removed. `neuraloperator` is not needed for
  this workflow (the model class is imported from the authors' `FNO_ERT/fno_demo_min.py`).
