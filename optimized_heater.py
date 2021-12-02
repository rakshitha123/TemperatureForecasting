#import argparse
import multiprocessing
from optimized_tester import testing
from tfrecords_handler.moving_window.tfrecord_writer import TFRecordWriter


if __name__ == '__main__':
    manager = multiprocessing.Manager()
    return_dict = manager.dict()

    args = {
        'dataset_name': 'lt_heating_cooling_optimization_1i1_',
        'contain_zero_values': 0,
        'binary_train_file_test_mode': 'datasets/binary_data/moving_window/without_stl_decomposition/heating/lecture_theatre/heating_1i1v.tfrecords',
        'binary_test_file_test_mode': 'datasets/binary_data/moving_window/without_stl_decomposition/optimization/lecture_theatre/heating_cooling_optimization_test_1i1.tfrecords',
        'cell_type': 'LSTM',
        'input_size': 2,
        'seasonality_period': 96,
        'forecast_horizon': 1,
        'hyperparameter_tuning': 'smac',
        'optimizer': 'cocob',
        'model_type': 'stacking',
        'input_format': 'moving_window',
        'without_stl_decomposition': 1,
        'seed': 1,
        'model_name': 'heating'
    }

    # Tuned hyperparameters of the heating model
    optimized_configuration = {'num_hidden_layers': 1.0,
                               'cell_dimension': 14.0,
                               'minibatch_size': 10.0,
                               'max_epoch_size': 6.0,
                               'max_num_epochs': 8.0,
                               'l2_regularization': 0.00019317137986724748,
                               'gaussian_noise_stdev': 0.00039607826362605654,
                               'random_normal_initializer_stdev': 0.0001229318699901891,
                               'rate_of_learning': 0.01}

    tfrecord_writer = TFRecordWriter(
        input_size=args['input_size'],
        output_size=args['forecast_horizon'],
        train_file_path='',
        validate_file_path='',
        test_file_path='./datasets/text_data/moving_window/without_stl_decomposition/optimization/lecture_theatre/heating_cooling_optimization_test_1i1.txt',
        binary_train_file_path='',
        binary_validation_file_path='',
        binary_test_file_path='./datasets/binary_data/moving_window/without_stl_decomposition/optimization/lecture_theatre/heating_cooling_optimization_test_1i1.tfrecords'
    )

    tfrecord_writer.read_text_data()
    tfrecord_writer.write_test_data_to_tfrecord_file()

    tfrecord_writer = None

    p = multiprocessing.Process(target=testing, args=(args, optimized_configuration, return_dict))
    p.start()
    p.join()
    forecasts = return_dict[0]


