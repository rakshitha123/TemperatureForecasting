# configs for the model training
class model_training_configs:
    INFO_FREQ = 1
    VALIDATION_ERRORS_DIRECTORY = 'results/errors/validation_errors/'

# configs for the model testing
class model_testing_configs:
    RNN_FORECASTS_DIRECTORY = 'results/rnn_forecasts/'
    SNAIVE_FORECASTS_DIRECTORY = 'results/snaive_forecasts/'
    RNN_PROCESSED_FORECASTS_FIRECTORY = 'results/processed_rnn_forecasts/'

# configs for hyperparameter tuning(bayesian optimization/SMAC3)
class hyperparameter_tuning_configs:
    BAYESIAN_INIT_POINTS = 5
    BAYESIAN_NUM_ITER = 100
    SMAC_RUNCOUNT_LIMIT = 50

class training_data_configs:
    SHUFFLE_BUFFER_SIZE = 20000

class gpu_configs:
    visible_device_list = "0, 1"
    log_device_placement = False