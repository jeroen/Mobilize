# TODO: Add comment
# 
# Author: jeroen
###############################################################################

responseplot.do <- function(dates, surveyvec, ...){

	#remove time
	dates <- as.Date(dates);
	dates <- factor(unclass(dates), levels=seq(min(dates), max(dates), by=1));
	
	#make into a dataframe	
	if(length(levels(surveyvec)) == 1){
		myData <- melt(table(dates));
		myData$survey <- levels(surveyvec);
		myData$survey <- as.factor(myData$survey);
		names(myData) <- c("date", "responses","survey");	
	} else {
		myData <- melt(sapply(split(surveyvec, dates),table));
		names(myData) <- c("survey", "date", "responses");			
	}

	#table converts it to a factor
	myData$date <- as.Date(myData$date);
	
	#make the plot
	survey <- myData$survey;
	myplot <- qplot(myData$date, myData$responses, fill=survey, stat="identity", geom=c("bar"), ...) + 
			scale_fill_hue(breaks = rev(levels(survey)));
	return(myplot);
	
}

#note: PASSING ON ... TO xxxxxplot.do ... has been disabled for now.
responseplot <- function(serverurl, token, campaign_urn, start_date="2010-01-01", end_date="2020-01-01", privacy_state="both", printurl=FALSE){
	
	if(printurl){
		print(geturl(match.call(expand.dots=T)));
	}
	
	myData <- oh.getdata(serverurl, token, campaign_urn, start_date = start_date, end_date=end_date, privacy_state=privacy_state, column_list="urn:ohmage:user:id,urn:ohmage:context:utc_timestamp,urn:ohmage:survey:id");
	
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	
	
	#HACK FOR GGPLOT BUG
	if(length(unique(as.Date(myData$context.utc_timestamp))) == 1){
		return(qplot(0,0,geom="text", label="not enough data to draw a timeseries (only 1 day).", xlab="", ylab=""));
	}
	###
	
	plottitle <- paste("responseplot: ", gsub("urn:campaign:","",campaign_urn), sep="");
	
	myplot <- responseplot.do(myData$context.utc_timestamp, myData$survey.id, xlab="", ylab="Response Count", main=plottitle)
}

