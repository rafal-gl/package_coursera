#' Load a FARS data file
#' 
#' This function loads a selected csv data file and returns a tibble
#' with coresponding variables. It is a wrapper for \code{\link{[readr]read_csv}}.
#' 
#' @param filename a character with a name of a file to be loaded
#' @return a tibble with the same structure as the input file
#' @note This function will return an error if it does not find a file 
#'  from filename parameter. Make sure you provide a proper file path.
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#' @export
#' @examples 
#' # set your wd to a directory with FARS data files
#' setwd("data")
#' fl <- "accident_2013.csv.bz2"
#' fars2013 <- fars_read(fl)
#' str(fars2013)

fars_read <- function(filename) {
  if(!file.exists(filename))
    stop("file '", filename, "' does not exist")
  data <- suppressMessages({
    readr::read_csv(filename, progress = FALSE)
  })
  dplyr::tbl_df(data)
}

#' Create a file name for FARS annual data
#' 
#' This function creates a file name of the structure: 
#' \code{accident_[YEAR].csv.bz2} given the year. 
#' 
#' @param year numeric or character with a year number
#' @return a character with the full file name
#' @note This function will return \code{"accident_NA.csv.bz2"} and 
#'  throw a warning if the year argument cannot be transoformed to integer
#' @export
#' @examples 
#' # acceptable input
#' make_filename(2015)
#' make_filename("2015")
#' # wrong input
#' make_filename("two thousand fifteen")

make_filename <- function(year) {
  year <- as.integer(year)
  sprintf("accident_%d.csv.bz2", year)
}

#' Load FARS data for multiple years 
#' 
#' This function loads data from FARS data files and 
#' puts them in a list of tibbles, year by year.  
#' 
#' @param years a vector or a list with years
#' @return a list with data tibbles year by year 
#' @note Missing data for any of the requested years will
#' result in a warning and a \code{NULL} in a coresponding
#' place in a return list. Set the working directory before running
#' this function.
#' @importFrom dplyr mutate select
#' @export
#' @examples 
#' # good years, but bad path
#' fars_from_2013_to_2015 <- fars_read_years(2013:2015)
#' fars_from_2013_to_2015
#' # the directory with data files must be a working directory
#' setwd("data")
#' fars_from_2013_to_2015 <- fars_read_years(2013:2015)
#' str(fars_from_2013_to_2015)
#' # invalid range results in NULLs
#' fars_from_2010_to_2013 <- fars_read_years(2010:2013)
#' str(fars_from_2013_to_2015)

fars_read_years <- function(years) {
  lapply(years, function(year) {
    file <- make_filename(year)
    tryCatch({
      dat <- fars_read(file)
      dplyr::mutate(dat, year = year) %>% 
        dplyr::select(MONTH, year)
    }, error = function(e) {
      warning("invalid year: ", year)
      return(NULL)
    })
  })
}

#' Count observations from FARS data files
#' 
#' This function loads FARS data fiels for requested years,
#' calculates observations per month in every year and returns 
#' the result in a tibble 
#' 
#' @param years a vector or a list with years
#' @return a tibble with numbers of observations in months
#' @note The function will return an error if no valid year
#' is given in the years parameter
#' @importFrom dplyr bind_rows group_by summarize
#' @importFrom tidyr spread
#' @export
#' @examples 
#' # full years range is covered in data
#' fars_summarize_years(2013:2015)
#' # no year is covered
#' fars_summarize_years(2011:2012)
#' # invalid years are removed
#' fars_summarize_years(2011:2014)

fars_summarize_years <- function(years) {
  dat_list <- fars_read_years(years)
  dplyr::bind_rows(dat_list) %>% 
    dplyr::group_by(year, MONTH) %>% 
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
}

#' Plot accidents on a map
#' 
#' Plot a state map with accidents as points. States are selected
#' by specifing their number from data files.
#' 
#' @param state.num numeric, a number of a state to plot
#' @param year numeric or character with year number
#' @return NULL, this function only plots
#' @note The function will return an error if there are no 
#' accidents registered in requested state and year or the 
#' state.num is invalid
#' @importFrom dplyr filter 
#' @importFrom graphics points
#' @importFrom maps map
#' @export
#' @examples 
#' fars_map_state(1, 2013)
#' fars_map_state(30, 2015)
#' # invalid state.num
#' fars_map_state(100, 2015)

fars_map_state <- function(state.num, year) {
  filename <- make_filename(year)
  data <- fars_read(filename)
  state.num <- as.integer(state.num)
  
  if(!(state.num %in% unique(data$STATE)))
    stop("invalid STATE number: ", state.num)
  data.sub <- dplyr::filter(data, STATE == state.num)
  if(nrow(data.sub) == 0L) {
    message("no accidents to plot")
    return(invisible(NULL))
  }
  is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
  is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
  with(data.sub, {
    maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
              xlim = range(LONGITUD, na.rm = TRUE))
    graphics::points(LONGITUD, LATITUDE, pch = 46)
  })
}