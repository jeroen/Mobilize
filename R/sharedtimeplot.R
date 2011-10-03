# TODO: Add comment
# 
# Author: jeroen
###############################################################################


sharedtimeplot.do <- function(dates, surveyvec, sharedvec, aggregate, ...){

	#remove time
	dates <- as.Date(dates);
	if(missing(aggregate)){
		totalperiod <- unclass(range(dates)[2] - range(dates)[1]);
		if(totalperiod < 30){
			mybinwidth <- 1;
		} else if (totalperiod < 180 ){
			mybinwidth <- 7;
		} else {
			mybinwidth <- 30;
		}
	} else {
		if(!is.numeric(aggregate)){
			stop("Argument aggregate has to be a number that represents the number of days to aggregate over.")
		}
		mybinwidth <- aggregate;
	}
	
	myData <- data.frame(date=dates, survey=surveyvec, privacy=sharedvec);
	myplot <- ggplot(aes(x=date, fill=privacy, group=privacy), data=myData) + geom_bar(binwidth=mybinwidth) + facet_wrap(~survey, ncol=1);
	return(myplot)
}

#note: PASSING ON ... TO xxxxxplot.do ... has been disabled for now.
sharedtimeplot <- function(campaign_urn, aggregate, ...){
	
	#printurl
	geturl(match.call(expand.dots=T));
	
	#grab data
	myData <- oh.survey_response.read(campaign_urn, column_list="urn:ohmage:survey:privacy_state,urn:ohmage:context:utc_timestamp,urn:ohmage:survey:id", ...);
	myData <- na.omit(myData);
	
	#check for no data
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	
	
	#draw plot
	plottitle <- paste("sharedtimeplot: ", gsub("urn:campaign:","",campaign_urn), sep="");
	myplot <- sharedtimeplot.do(myData$context.utc_timestamp, myData$survey.id, myData$survey.privacy_state, aggregate=aggregate, xlab="", ylab="Response Count", main=plottitle);
	return(myplot)
}
