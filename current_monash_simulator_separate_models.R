# Simulate the thermal behaviour of the lecture theatre during normal occupied periods.
# The inside temperature will be always maintained within the given lower and upper setpoints.

library(reticulate)

use_virtualenv("./anaconda3/envs/python_venv")

OUTPUT_DIR = "./datasets/text_data/moving_window/without_stl_decomposition/optimization/lecture_theatre"
file <- read.csv(file = "./datasets/text_data/winter_lt_data.csv")
max_forecast_horizon <- 1
input_size <- 1
mean <- 20
outside_mean <- 20
finalForecasts <- c()
times <- c()
OUTPUT_PATH <- paste(OUTPUT_DIR, "/heating_cooling_optimization_test_", max_forecast_horizon, "i", input_size, ".txt", sep = '')


#These variables need to be set before running the script if need
lower_setpoint <- 19
upper_setpoint <- 20
start_inside_temperature <- 20
start_status <- 0 # 0 if the AC is switched off and 1 if the AC is switched on
total_minutes <- 300 # total simulation time
isCoolingStarted <- TRUE  #FALSE when starting from morning
time_required_to_add <- 420 # if the simulation is started during the middle of a day, what is the total time it should add to get the current time (in minutes)
outside_temperature_start_index <- 6711 # start index of the outside temperatures corresponding with our data
outside_temperature_finish_index <- 6731 # finish index of the outside temperatures corresponding with our data
output_file_name <- "sep5_1pm_to_6pm_optimized_20"


getPredictions <- function(insideTemperature, outsideTemperature, status){
    sav_df <- data.frame(id=paste(1,'|i',sep=''))
    sav_df[,paste('r',1,sep='')] <- insideTemperature/mean
    sav_df[,paste('a',1,sep='')] <- outsideTemperature/outside_mean
    sav_df[,'nyb'] <- '|#'
    sav_df[,'level'] <- mean
    write.table(sav_df, file=OUTPUT_PATH, row.names = F, col.names=F, sep=" ", quote=F, append = TRUE)

    if(status==1){
         py_run_file("./optimized_heater.py")
    }
    else{
        py_run_file("./optimized_cooler.py")
    }
    forecasts <- py$forecasts[[1]]
    final_temperature <- as.numeric(forecasts[length(forecasts)])
    final_temperature
}


simulate <- function(){
    close( file( OUTPUT_PATH, open="w" ) )
    currentForecast <- start_inside_temperature
    currentStatus <- start_status
    outsideTemperatures <- file$outside_temp
    outsideTemperatures <- outsideTemperatures[outside_temperature_start_index:outside_temperature_finish_index]
    time <- 0
    prevForecast <- currentForecast

    while(time<total_minutes){
        index <- (floor(time/15))+1
        currentForecast <- getPredictions(currentForecast, outsideTemperatures[index],currentStatus)
        currentForecast <- currentForecast*mean
        prevStatus <- currentStatus

        if((currentForecast < lower_setpoint) & isCoolingStarted){
            rate <- (prevForecast-currentForecast)/15
            requiredTime <- (prevForecast-lower_setpoint)/rate
            time <- time + requiredTime
            currentForecast <- lower_setpoint
        }
        else if(currentForecast > upper_setpoint){
            rate <- (currentForecast-prevForecast)/15
            requiredTime <- (currentForecast-upper_setpoint)/rate
            time <- time + requiredTime
            currentForecast <- upper_setpoint
        }
        else{
            time <- time + 15
        }

        finalForecasts <<- c(finalForecasts,currentForecast)
        times <<- c(times,(time+time_required_to_add))
        if(currentForecast >= upper_setpoint){
            isCoolingStarted <- TRUE
            currentStatus <- 0
        }
        else if(currentForecast <= lower_setpoint){
            currentStatus <- 1
        }
        else{
            currentStatus <- prevStatus
        }
        if(currentStatus != prevStatus){
            close( file( OUTPUT_PATH, open="w" ) )
        }
        prevForecast <- currentForecast
    }

    output <- data.frame(forecast=finalForecasts, time=times)
    forecasts_file_path <- paste('./results/monash_simulation/',output_file_name,'.txt')
    write.csv(output, file=forecasts_file_path)
}

simulate()






