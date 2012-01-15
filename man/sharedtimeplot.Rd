\name{sharedtimeplot}
\alias{sharedtimeplot}
\title{Timeseries plot of the number of shared and unshared responses per campaign}
\usage{
  sharedtimeplot(campaign_urn, aggregate, ...)
}
\arguments{
  \item{campaign_urn}{campaign id}

  \item{aggregate}{number of days to aggregate over.
  Optional. Defaults to something smart.}

  \item{...}{other arguments passed to
  oh.survey_response.read}
}
\value{
  a ggplot2 object
}
\description{
  Timeseries plot of the number of shared and unshared
  responses per campaign
}

