\name{timeplot}
\alias{timeplot}
\title{Timeseries plot of a prompt}
\usage{
timeplot(campaign_urn, prompt_id, aggregate, ...)
}
\arguments{
  \item{campaign_urn}{campaign id}

  \item{prompt_id}{prompt id}

  \item{aggregate}{number of days to aggregate over.
  Defaults to something smart.}

  \item{...}{other arguments passed on to
  oh.survey_response.read}
}
\value{
ggplot2 plot object
}
\description{
Timeseries plot of a prompt
}

