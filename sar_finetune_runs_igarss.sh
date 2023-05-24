#!/bin/bash
WANDB_PROJECT=SAR_SimCR_finetune_IGARSS_final
simclr_run=(/work/08452/kaipak/ls6/model_output/SimCLR_SAR/lr_0.15_epochs_250_bs_1026)
test_sets=(/home1/08452/kaipak/clover_shared/datasets/California_SAR_Eddies_V2/LocatedEddies_bbupdate20220127/tiles/
           /home1/08452/kaipak/clover_shared/corral/datasets/gee_sar_100k_reference_v1.0.0523/)

gpu_id=(0 1 2)
gpu_jobs=${#gpu_id[@]}
logistic_learning_rates=(0.0001)
checkpoints=(9, 49, 99, 149, 199, 249)
debug=True

while getopts "p:d:" opt
do
  case "$opt" in
    d ) dataset=${OPTARG};;
    p ) dataset_dir=${OPTARG};;
  esac
done

for test_set in ${test_sets[@]}; do
  for check_point in ${checkpoints[@]}; do
    echo "Running linear eval on ${simclr_run}, checkpoing {check_point} with ${test_set} on GPU ${gpu}"
    if $debug; then
      echo "CUDA_VISIBLE_DEVICES=${gpu_id[$gpu_jobs - 1]} python ../linear_evaluation/linear_evaluation/finetune.py
        --config ../linear_evaluation/config/sat_ft_simclrv2.yaml \
              --test_dir ${dataset} \
          --pretrain ${simclr_run}/checkpoint_${check_point}.tar \
              --wandb_project  ${WANDB_PROJECT}\"
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

