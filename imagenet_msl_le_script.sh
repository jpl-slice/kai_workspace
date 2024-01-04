#!/bin/bash

simclr_runs=(/work/08452/kaipak/ls6/model_output/SimCLR_refactor_pretrain_experiments_combined250k250k_lr0.15_epochs100)
gpu_id=(0 1 2)
gpu_jobs=${#gpu_id[@]}
logistic_learning_rates=(0.0003 0.003 0.03)
debug=false

while getopts "p:d:" opt
do
  case "$opt" in
    d ) dataset=${OPTARG};;
    p ) dataset_dir=${OPTARG};;
  esac
done

for simclr_run in ${simclr_runs[@]}; do
  for learning_rate in ${logistic_learning_rates[@]}; do
    echo "Running linear eval on ${simclr_run} with lr ${learning_rate} on GPU ${gpu}"
    if $debug; then
      echo "CUDA_VISIBLE_DEVICES=${gpu_id[$gpu_jobs - 1]} python ../SimCLR/run_ckpt_logistic_pct_loop.py
	      --config ../SimCLR/config/imagenet_baseline.yaml
              --dataset ${dataset}
  	      --dataset_dir ${dataset_dir}
              --model_path ${simclr_run}
              --use_wandb \"True\"
              --wandb_project SimCLR_refactor_pretrain_experiments \
              --use_file_map True \
              --logistic_learning_rate ${learning_rate}"
    else
      CUDA_VISIBLE_DEVICES=${gpu_id[$gpu_jobs - 1]} python ../SimCLR_CLOVER/run_ckpt_logistic_pct_loop.py \
	      --config SimCLR_configs/msl_large_bs_config.yaml \
  	      --dataset ${dataset} \
  	      --dataset_dir ${dataset_dir} \
  	      --model_path ${simclr_run} \
  	      --use_wandb True \
              --wandb_project SimCLR_refactor_pretrain_experiments \
	      --use_file_map True \
              --logistic_learning_rate ${learning_rate} &
    fi
    ((gpu_jobs--))

    if [[ $gpu_jobs -eq 0 ]]; then
      wait
	echo "Waiting for previous jobs to complete..."
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	gpu_jobs=${#gpu_id[@]}
    fi
  done
done

