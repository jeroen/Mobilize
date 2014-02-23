\name{scatterplot}
\alias{scatterplot}
\title{Create a scatterplot of two prompts}
\usage{
scatterplot(campaign_urn, prompt_id, prompt2_id, jitter = TRUE, ...)
}
\arguments{
  \item{campaign_urn}{id of the campaign}

  \item{prompt_id}{prompt on the x axis.}

  \item{prompt2_id}{prompt on the y axis}

  \item{jitter}{T/F. If points should be jittered}

  \item{...}{arguments passed on to
  oh.survey_response.read}
}
\value{
ggplot2 object
}
\description{
Create a scatterplot of two prompts
}

