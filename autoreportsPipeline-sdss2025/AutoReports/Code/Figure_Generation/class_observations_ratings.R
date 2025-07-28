determine_class_observation_ratings <- function(df, column_name) {
  averages <- df[[column_name]]$Average
  ratings <- character(length(averages))

  if (length(averages) == 0) {
    ratings <- c("Low")
  }

  for (i in seq_along(averages)) {
    if (averages[i] <= 2.5) {
      ratings[i] <- "Low"
    } else if (averages[i] <= 5.5) {
      ratings[i] <- "Middle"
    } else {
      ratings[i] <- "High"
    }
  }

  return(ratings)
}


determine_obs_count <- function(df, column_name) {
  count_index <- which(df[[column_name]]$n== max(df[[column_name]]$n))

  if (length(count_index) > 1) {
    largest_ave <- df[[column_name]]$Average[count_index[1]]
    ind <- count_index[1] # Initialize ind with the first index
    for (i in 2:length(count_index)) { # Start from the second index
      if (largest_ave < df[[column_name]]$Average[count_index[i]]) {
        largest_ave <- df[[column_name]]$Average[count_index[i]]
        ind <- count_index[i]
      }
    }
  } else {
    ind <- count_index
  }

  return(ind)
}
