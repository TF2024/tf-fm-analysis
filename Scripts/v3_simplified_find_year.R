v3_simplified_find_year <- function(date, case_start) {
  date <- as.Date(date)
  case_start <- as.Date(case_start)
  
  if (is.na(date) || is.na(case_start)) {
    return(NA)
  }
  
  date_year <- as.numeric(format(date, "%Y"))
  case_start_year <- as.numeric(format(case_start, "%Y"))
  
# If activity year is before start year, return 1  
  if(date_year < case_start_year) {
    return(1)
    
# If activity year is the same as start year, return 1
  } else if(date_year == case_start_year) {
    return(1)
    
# If activity year is after start year, return the difference in years (+1)
  } else {
    prog_year <- date_year - case_start_year + 1
    
    
# If the programme year generated is >5, return 5 
    if (prog_year > 5) {
      return(5) 
    } else {
      return(prog_year)
    }
  }
}





