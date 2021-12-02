OUTPUT_DIR = "./datasets/text_data/moving_window/without_stl_decomposition/heating/lecture_theatre"

heating_file <- read.csv(file = "./datasets/text_data/heating_cooling_data/full_heating.csv", header=FALSE) # Contains the extracted inside heating series
heating_outside_file <- read.csv(file = "./datasets/text_data/heating_cooling_data/full_heating_outside.csv", header=FALSE) # Contains the extracted outside heating series

max_forecast_horizon <- 1
input_size <-1
mean <- 20

OUTPUT_PATH <- paste(OUTPUT_DIR, "/heating_", max_forecast_horizon, "i" , input_size , ".txt", sep = '')

heating_file <- as.matrix(as.data.frame(lapply(heating_file, as.numeric)))
heating_outside_file <- as.matrix(as.data.frame(lapply(heating_outside_file, as.numeric)))


processData <- function(inside_file, outside_file){
  for (idr in 1 : ncol(inside_file)) {
    inside <- inside_file[,idr][!is.na(inside_file[,idr])]
    outside <- outside_file[,idr][!is.na(outside_file[,idr])]
    
    time_series <- inside/mean
    outside_time_series <- outside/mean

    time_series_length <- length(time_series)
    time_series_length <- time_series_length - 1

    
    for (inn in input_size:(time_series_length-max_forecast_horizon)) {  
      sav_df <- data.frame(id=paste(idr,'|i',sep=''));
      
      for (ii in 1:input_size) {
        sav_df[,paste('r',ii,sep='')] <- time_series[inn-input_size+ii]  #inputs: past values normalized by the level
      }
      
      for (ii in 1:input_size) {
        sav_df[,paste('a',ii,sep='')] <- outside_time_series[inn-input_size+ii]
      }

      sav_df[,'o'] <- '|o'
      for (ii in 1:max_forecast_horizon) {
        sav_df[,paste('o',ii,sep='')] <- time_series[inn+ii] #outputs: future values normalized by the level.
      }
      
      write.table(sav_df, file=OUTPUT_PATH, row.names = F, col.names=F, sep=" ", quote=F, append = TRUE)
    }
    
    print(idr)
  }
}

processData(heating_file,heating_outside_file)



