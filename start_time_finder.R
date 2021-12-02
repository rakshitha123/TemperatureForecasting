# Find the optimal time to switch on the AC in the morning.

library(reticulate)

use_virtualenv("./anaconda3/envs/python_venv")

OUTPUT_DIR = "./datasets/text_data/moving_window/without_stl_decomposition/optimization/lecture_theatre"
file <- read.csv(file = "./datasets/text_data/winter_lt_data.csv")
max_forecast_horizon <- 1
input_size <- 1
mean <- 20
outside_mean <- 20
OUTPUT_PATH <- paste(OUTPUT_DIR, "/heating_cooling_optimization_test_", max_forecast_horizon, "i", input_size, ".txt", sep = '')


#These variables should be set if required
lower_setpoint <- 19
prev_times <- 8  # number of 15 minute intervals between the scheduled start time and 6am (which is the time the AC is usually switched on)
start_index <- 6683  # the index of 6am corresponding with our data
finish_index <- 6690   # the index of the scheduled start time corresponding with our data
replaceInsideTemperatures <- FALSE
output_file_name <- "sep5_start_time"



getPredictions <- function(insideTemperature, outsideTemperature){
    sav_df <- data.frame(id=paste(1,'|i',sep=''))
    sav_df[,paste('r',1,sep='')] <- insideTemperature/mean
    sav_df[,paste('a',1,sep='')] <- outsideTemperature/outside_mean
    sav_df[,'nyb'] <- '|#'
    sav_df[,'level'] <- mean
    write.table(sav_df, file=OUTPUT_PATH, row.names = F, col.names=F, sep=" ", quote=F, append = TRUE)
    py_run_file("./optimized_heater.py")
    forecasts <- py$forecasts[[1]]
    final_temperature <- as.numeric(forecasts[length(forecasts)])
    final_temperature
}


find_start_time <-function(){
    forecasts <- c()
    outsideTemperatures <- file$outside_temp
    insideTemperatures <- file$lt_temp
    outsideTemperatures <- outsideTemperatures[start_index:finish_index]

    if(replaceInsideTemperatures){
         insideTemperatures <- outsideTemperatures
    }else{
         insideTemperatures <- insideTemperatures[start_index:finish_index]
    }

    for(t in prev_times:1){
        close( file( OUTPUT_PATH, open="w" ) )
        required_num_of_forecasts <- prev_times-t+1
        currentForecast <- insideTemperatures[t]
        outside_index <- t
        for(i in required_num_of_forecasts:1){
            currentForecast <- getPredictions(currentForecast,outsideTemperatures[outside_index])
            currentForecast <- currentForecast*mean
            forecasts <- c(forecasts,currentForecast)
            outside_index <- outside_index + 1
        }
        if(currentForecast>lower_setpoint){
            forecasts_file_path = paste('./results/all_forecasts/',output_file_name,'.txt')
            write.csv(forecasts, forecasts_file_path)
            time <- length(forecasts)*15
            print(paste("AC should be switched on ",time, " minutes before occupying the room"))
            break;
        }
        else{
            forecasts <- c()
        }
    }


}

find_start_time()
