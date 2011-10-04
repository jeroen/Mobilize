# TODO: Add comment
# 
# Author: jeroen
###############################################################################

responseplot.do <- function(dates, surveyvec, aggregate, ...){
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
	
	myData <- data.frame(date=dates, survey=surveyvec);
	myplot <- ggplot(aes(x=date, fill=survey), data=myData) + geom_bar(binwidth=mybinwidth);
	return(myplot);	
}

#note: anything in ... will be passed to the server
responseplot <- function(campaign_urn, aggregate, ...){

	#secret argument printurl for debugging
	geturl(match.call(expand.dots=T))
	
	#retrieve data
	myData <- oh.survey_response.read(campaign_urn=campaign_urn, column_list="urn:ohmage:context:utc_timestamp,urn:ohmage:survey:id", ...);
	if(nrow(myData) > 0) myData <- na.omit(myData);
	
	#empty plot
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab="Response Count"));
	}	
	
	#create plot:	
	plottitle <- paste("responseplot: ", gsub("urn:campaign:","",campaign_urn), sep="");
	myplot <- responseplot.do(myData$context.utc_timestamp, myData$survey.id, aggregate=aggregate, xlab="", ylab="Response Count", main=plottitle)
}

