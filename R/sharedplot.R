# TODO: Add comment
# 
# Author: jeroen
###############################################################################


sharedplot.do <- function(surveyvec, sharedvec, ...){
	survey <- surveyvec;
	privacy <- sharedvec;
	myplot <- qplot(survey, geom="bar", group=privacy, fill=privacy, ...) + scale_fill_hue(breaks = rev(levels(privacy)));
	return(myplot);	
}

#note: PASSING ON ... TO xxxxxplot.do ... has been disabled for now.
sharedplot <- function(serverurl, token, campaign_urn, start_date="2010-01-01", end_date="2020-01-01", printurl=FALSE){
	
	if(printurl){
		print(geturl(match.call(expand.dots=T)));
	}
	
	myData <- oh.getdata(serverurl, token, campaign_urn, start_date = start_date, end_date=end_date, column_list="urn:ohmage:survey:privacy_state,urn:ohmage:survey:id");
	
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	
	
	plottitle <- paste("sharedplot: ", gsub("urn:campaign:","",campaign_urn), sep="");
	
	myplot <- sharedplot.do(myData$survey.id, myData$survey.privacy_state, xlab="", ylab="Response Count", main=plottitle)
}