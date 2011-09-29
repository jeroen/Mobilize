# TODO: Add comment
# 
# Author: jeroen
###############################################################################


sharedtimeplot.do <- function(dates, surveyvec, sharedvec, ...){

	#remove time
	dates <- as.Date(dates);
	dates <- factor(unclass(dates), levels=seq(min(dates), max(dates), by=1));
	
	#count responses
	myData <- melt(sapply(split(data.frame(surveyvec,dates), sharedvec), table, simplify=F));
	names(myData) <- c("survey", "date", "responses", "privacy");
	myData$date <- as.Date(myData$date);	

	#make the plot
	myplot <- qplot(date, responses, data=myData, fill=privacy, group=privacy, stat="identity", geom="bar", ...) +
			scale_fill_hue(breaks = rev(levels(myData$privacy)));
	
	#facet for more than 1 survey
	if(length(levels(surveyvec)) > 1){
		myplot <- myplot + facet_wrap(~survey, ncol=1);
	}
	
	return(myplot);
}

#note: PASSING ON ... TO xxxxxplot.do ... has been disabled for now.
sharedtimeplot <- function(serverurl, token, campaign_urn, start_date="2010-01-01", end_date="2020-01-01", printurl=FALSE){
	
	if(printurl){
		print(geturl(match.call(expand.dots=T)));
	}
	
	myData <- oh.getdata(serverurl, token, campaign_urn, start_date = start_date, end_date=end_date, column_list="urn:ohmage:survey:privacy_state,urn:ohmage:context:utc_timestamp,urn:ohmage:survey:id");
	
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	
	
	#HACK FOR GGPLOT BUG
	if(length(unique(as.Date(myData$context.utc_timestamp))) == 1){
		return(qplot(0,0,geom="text", label="not enough data to draw a timeseries.", xlab="", ylab=""));
	}	
	
	plottitle <- paste("sharedtimeplot: ", gsub("urn:campaign:","",campaign_urn), sep="");
	
	myplot <- sharedtimeplot.do(myData$context.utc_timestamp, myData$survey.id, myData$survey.privacy_state, xlab="", ylab="Response Count", main=plottitle)
}
