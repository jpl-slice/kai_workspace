#!/bin/bash
WANDB_PROJECT=SAR_SimCLR_finetune_IGARSS_final
simclr_run=(/work/08452/kaipak/ls6/model_output/SimCLR_SAR/lr_0.1_epochs_250_bs_1026)
test_sets=(/home1/08452/kaipak/clover_shared/datasets/California_SAR_Eddies_V2/LocatedEddies_bbupdate20220127/tiles/
           /home1/08452/kaipak/clover_shared/corral/datasets/gee_sar_100k_reference_v1.0.0523/)
test_files=(/home1/08452/kaipak/clover_shared/datasets/California_SAR_Eddies_V2/LocatedEddies_bbupdate20220127/tiles/pos_centroids_and_bg_tile_labs.csv
            /home1/08452/kaipak/clover_shared/corral/datasets/gee_sar_100k_reference_v1.0.0523/test_med_subset_linear_labels.csv)

gpu_id=(0 1 2)
gpu_jobs=${#gpu_id[@]}
logistic_learning_rates=(0.0001)
splits=(1 10 20 50)
debug=false

while getopts "p:d:" opt
do
  case "$opt" in
    d ) dataset=${OPTARG};;
    p ) dataset_dir=${OPTARG};;
  esac
done

for test_set_idx in {0..1}; do
  for split in ${splits[@]}; do
    echo "Starting job on ${gpu_id[$gpu_jobs - 1]}"
    CUDA_VISIBLE_DEVICES=${gpu_id[$gpu_jobs - 1]} python ../linear_evaluation/linear_evaluation/finetune.py \
      --config ../linear_evaluation/config/sar_ft_simclrv2.yaml \
      --train_file_map /home1/08452/kaipak/clover_shared/corral/datasets/gee_sar_100k_reference_v1.0.0523/validation_med_subset_linear_labels_${split}pct.csv \
      --test_dir ${test_sets[$test_set_idx]} \
      --test_file_map ${test_files[$test_set_idx]} \
      --pretrain ${simclr_run}/checkpoint_199.tar \
      --wandb_project ${WANDB_PROJECT} &
    ((gpu_jobs--))

    if [[ $gpu_jobs -eq 0 ]]; then
      wait
      echo "Waiting for previous jobs to complete..."
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      gpu_jobs=${#gpu_id[@]}
    fi
  done
done

