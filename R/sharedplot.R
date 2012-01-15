# TODO: Add comment
# 
# Author: jeroen
###############################################################################


sharedplot.do <- function(surveyvec, sharedvec, ...){
	survey <- surveyvec;
	privacy <- sharedvec;
	myplot <- qplot(survey, geom="bar", group=privacy, fill=privacy, ...);
	return(myplot);	
}


#' A barchart of the number of shared and unshared responses per campaign
#' @param campaign_urn campaign id
#' @param ... arguments passed on to oh.survey_response.read
#' @return a ggplot2 object 
#' @export
sharedplot <- function(campaign_urn, ...){
	
	#check for secret 'printurl' argument
	geturl(match.call(expand.dots=T));
	
	#get data
	myData <- oh.survey_response.read(campaign_urn, column_list="urn:ohmage:survey:privacy_state,urn:ohmage:survey:id", ...);
	if(nrow(myData) > 0) myData <- na.omit(myData);
	
	#check if we have some data
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	
	
	#make plot
	plottitle <- paste("sharedplot: ", gsub("urn:campaign:","",campaign_urn), sep="");
	myplot <- sharedplot.do(myData$survey.id, myData$survey.privacy_state, xlab="", ylab="Response Count", main=plottitle);
	
	#return
	return(myplot);
}