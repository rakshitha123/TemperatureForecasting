#!/usr/bin/env bash

# Hyperparameter tuning of cooling model
python ./generic_model_trainer.py --dataset_name lt_full_cooling_ --contain_zero_values 0 --initial_hyperparameter_values_file configs/initial_hyperparameter_values/temperature --binary_train_file_train_mode datasets/binary_data/moving_window/without_stl_decomposition/cooling/lecture_theatre/full_cooling_1i1.tfrecords --binary_valid_file_train_mode datasets/binary_data/moving_window/without_stl_decomposition/cooling/lecture_theatre/full_cooling_1i1v.tfrecords --cell_type LSTM --input_size 2 --forecast_horizon 1 --optimizer cocob --hyperparameter_tuning smac --model_type stacking --input_format moving_window --seasonality_period 96 --without_stl_decomposition 1 --seed 1 &


# Hyperparameter tuning of heating model
python ./generic_model_trainer.py --dataset_name lt_full_heating --contain_zero_values 0 --initial_hyperparameter_values_file configs/initial_hyperparameter_values/temperature --binary_train_file_train_mode datasets/binary_data/moving_window/without_stl_decomposition/heating/lecture_theatre/heating_1i1.tfrecords --binary_valid_file_train_mode datasets/binary_data/moving_window/without_stl_decomposition/heating/lecture_theatre/heating_1i1v.tfrecords --cell_type LSTM --input_size 2 --forecast_horizon 1 --optimizer cocob --hyperparameter_tuning smac --model_type stacking --input_format moving_window --seasonality_period 96 --without_stl_decomposition 1 --seed 1 &

