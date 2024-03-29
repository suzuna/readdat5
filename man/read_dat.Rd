% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_dat.R
\name{read_dat}
\alias{read_dat}
\title{Read a dat file of 5ch and return a tibble}
\usage{
read_dat(file, br_char = "[br]", encoding = "Shift-JIS")
}
\arguments{
\item{file}{a string. a path to a dat file.}

\item{br_char}{a string which represents "<br>" (new line) in responses ("res" in Japanese).
It is not allowed to use a string which contains "<" and ">".}

\item{encoding}{a string. encoding of a file.}
}
\value{
a tibble. Here is columns of the tibble.
\itemize{
  \item{dat_id} {character. a filename of a dat file.}
  \item{thread_title} {character. a title of a thread.}
  \item{res_number} {integer. the number of a response.}
  \item{name} {character. a name of a response.}
  \item{mail} {character. a string of mail form.}
  \item{datetime} {character. a datetime which a response is posted.}
  \item{id} {character. an id of a response.}
  \item{be} {character. a be of a response.}
  \item{content} {character. a content of a response.}
}
}
\description{
Read a dat file of 5ch and return a tibble
}
\examples{
\dontrun{
read_dat("foo.dat",br_char="[br]",encoding="Shift-JIS")
}
}
