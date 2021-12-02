# Find the time that the AC should be switched on during an unoccupied period.

library(GA)
library(reticulate)

use_virtualenv("./anaconda3/envs/python_venv")

OUTPUT_DIR = "./datasets/text_data/moving_window/without_stl_decomposition/optimization/lecture_theatre"
file <- read.csv(file = "./datasets/text_data/winter_lt_data.csv")
max_forecast_horizon <- 1
input_size <- 1
mean <- 20
outside_mean <- 20
initial_forecasts <- c()
OUTPUT_PATH <- paste(OUTPUT_DIR, "/heating_cooling_optimization_test_", max_forecast_horizon, "i", input_size, ".txt", sep = '')


#These variables should be set if required
lower_setpoint <- 19
upper_setpoint <- 20
start_inside_temperature <- 19.56
required_num_of_forecasts <- 8 # number of 15 minute intervals within the unoccupied period (ex: for a 2 hour unoccupied period, there are eight 15 minute intervals)
outside_temperature_start_index <- 6703 # start index of the outside temperature corresponding with our data
outside_temperature_finish_index <- 6711 # finish index of the outside temperature corresponding with our data
output_file_name <- "sep5_11am_1pm"


# Generate the initial population for genetic algorithm
initial_population <- function(object) {
    init <- matrix(, nrow = object@popSize, ncol = object@nBits)

    for(i in 0:(object@popSize-1)){
        current <- rep(0,object@nBits-i)
        ones <- rep(1, i)
        current <- c(current, ones)
        init[i+1,] <- current
    }
    return(init)
}


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



# Genetic algorithm fitness function
f <-function(z){
    close( file( OUTPUT_PATH, open="w" ) )
    temperature_score <- 0
    currentForecast <- start_inside_temperature
    outsideTemperatures <- file$outside_temp
    outsideTemperatures <- outsideTemperatures[outside_temperature_start_index:outside_temperature_finish_index]

    if((sum(z == 0))==length(z)){
        for(t in 1:length(z)){
            currentForecast <- getPredictions(currentForecast,outsideTemperatures[t] ,0)
            currentForecast <- currentForecast*mean
            print(currentForecast)
            initial_forecasts <<- c(initial_forecasts,currentForecast)
        }
        finalForecasts <- initial_forecasts
    }
    else{
        close( file( OUTPUT_PATH, open="w" ) )
        oneCount <- sum(z==1)
        finalForecasts <- initial_forecasts[1:(required_num_of_forecasts-oneCount)]
        currentForecast <- initial_forecasts[required_num_of_forecasts-oneCount]
        for(t in oneCount:1){
            currentForecast <- getPredictions(currentForecast, outsideTemperatures[required_num_of_forecasts-t], 1)
            currentForecast <- currentForecast*mean
            print(currentForecast)
            finalForecasts <- c(finalForecasts,currentForecast)
        }
    }

    forecasts_file_path = paste('./results/all_forecasts/',output_file_name,'.txt')
    write.table(t(finalForecasts), file=forecasts_file_path, row.names = F, col.names=F, sep=" ", quote=F, append = TRUE)

    final_temperature <- currentForecast
    print(final_temperature)

    if(final_temperature>=lower_setpoint && final_temperature<=upper_setpoint){
        temperature_score <- 10
    }

    sum(z == 0) + temperature_score
}

result <- ga(type="binary",
             fitness=f,
             nBits=required_num_of_forecasts,
             popSize=required_num_of_forecasts,
             parallel=FALSE,
             pmutation = 0,
             pcrossover = 0,
             population = initial_population,
             selection = ga_rwSelection,
             run=2,
             seed=1)
generated_setpoints <- summary(result)$solution[1,]
print(generated_setpoints)


