# TemperatureForecasting

This repository contains the experiments of our recent study related to the optimisation of Air Conditioning (AC) systems which is published at the [IEEE Access](https://doi.org/10.1109/ACCESS.2022.3142174).
In this work, we introduce a deep learning framework that trains across time series that can forecast the temperatures of a future period directly where a particular room is unoccupied and optimises the setpoints of the room. In contrast to traditional forecasting approaches that build isolated models to predict each series, our framework uses
global Recurrent Neural Network (RNN) models that are trained with a set of relatively short temperature series, allowing the models to learn the cross-series information. The predicted temperatures were then used to define the optimal thermal setpoints to be used inside the room during the unoccupied periods. 


# Instructions for Execution
Our RNN implementations are mainly based on the Tensorflow based framework implemented by Hewamalage et al., 2021.

We use a temperature dataset of a lecture theatre of Monash University, Australia for our experiments and thus, we are not authorized to release the dataset.

We first extracted the heating and cooling series separately from the temperature dataset. We then, preprocessed the extracted heating and cooling series using the scripts inside "./preprocess_scripts" folder. The preprocessed data were used to train 2 RNN models: one to model cooling and the other one to model heating. The hyperparameters of these heating and cooling RNNs were optimsied using the 2 commands mentioned in the script, "./temperature_experiments.sh". The cooling and heating RNNs related optimised parameters were respectively updated in "optimized_cooler.py" and "optimized_heater.py" scripts.

The AC optimisation process was started after tuning the parameters. For that, we mainly used 3 R scripts as follows:
 - start_time_finder.R: Find the optimal time point that the AC should be switched on in the morning in a way that it uses a minimum amount of energy to heat the room.
 - optimizer_heating_cooling.R: Find the optimal time point that the AC should be switched on during an unoccupied period of a particular room.
 - current_monash_simulator_separate_models.R: Simulate the thermal behaviour inside a room in a way that it always maintains the inside temperature of the room within the given lower and upper setpoints.

The individual parameters used by the scripts are explained within them. For more details, please refer to our [paper](https://doi.org/10.1109/ACCESS.2022.3142174).


# Citing Our Work
When using this repository, please cite:

```{r} 
@article{godahewa2022energy,
  title = {A Generative Deep Learning Framework Across Time Series to Optimise the Energy Consumption of Air Conditioning Systems},
  author = {Godahewa, Rakshitha and Deng, Chang and Prouzeau, Arnaud and Bergmeir, Christoph},
  journal = {IEEE Access},
  year = {2022},
  doi = {10.1109/ACCESS.2022.3142174}
}
```

# References
Hewamalage H., Bergmeir C., Bandara K. (2021) Recurrent neural networks for time series forecasting: Current status and future directions. International Journal of Forecasting DOI https://doi.org/10.1016/j.ijforecast.2020.06.008.
