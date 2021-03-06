% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fars_functions.R
\name{fars_map_state}
\alias{fars_map_state}
\title{Plot accidents on a map}
\usage{
fars_map_state(state.num, year)
}
\arguments{
\item{state.num}{numeric, a number of a state to plot}

\item{year}{numeric or character with year number}
}
\value{
NULL, this function only plots
}
\description{
Plot a state map with accidents as points. States are selected
by specifing their number from data files.
}
\note{
The function will return an error if there are no 
accidents registered in requested state and year or the 
state.num is invalid
}
\examples{
fars_map_state(1, 2013)
fars_map_state(30, 2015)
# invalid state.num
fars_map_state(100, 2015)
}
