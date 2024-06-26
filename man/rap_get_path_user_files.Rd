% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rap.R
\name{rap_get_path_user_files}
\alias{rap_get_path_user_files}
\title{Get the paths of files in a single users folder within the RAP project server.}
\usage{
rap_get_path_user_files(user = rap_get_user())
}
\arguments{
\item{user}{A user's username. Default is currently logged in user.}
}
\value{
A character vector of files in a user's folder.
}
\description{
Get the paths of files in a single users folder within the RAP project server.
}
\examples{
\dontrun{
rap_get_path_user_files("danibs")
}
}
