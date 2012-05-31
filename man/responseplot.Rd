\name{responseplot}
\alias{responseplot}
\title{Create a responseplot}
\usage{
  responseplot(campaign_urn, aggregate,
    privacy_state = "both", ...)
}
\arguments{
  \item{campaign_urn}{id of the campaign}

  \item{aggregate}{optional number of days to aggregate
  over. Defaults to something smart.}

  \item{privacy_state}{either "shared" or "private" or
  "both"}

  \item{...}{stuff to pass on to oh.survey_response.read}
}
\value{
  a responseplot
}
\description{
  Create a responseplot
}

