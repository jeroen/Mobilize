# TODO: Add comment
# 
# Author: jeroen
###############################################################################

userplot.POSIXct <- function(values, dates, ...){
	myplot <- timeplot.POSIXct(values, dates, ...);
	return(myplot);
}

userplot.hours_before_now <- function(values, dates, ...){
	myplot <- timeplot.hours_before_now(values, dates, ...);
	return(myplot);
}

userplot.multifactor <- function(values, dates, ...){
	newvalues <- as.vector(values);
	newdates <- rep(dates, dim(values));
	userplot.do(newvalues, newdates, ...);
}

userplot.numeric <- function(values, dates, ...){
	myplot <- timeplot.numeric(values, dates, ...);
	return(myplot);
}

userplot.factor <- function(values, dates, ...){
	dates <- as.Date(dates);
	dates <- factor(unclass(dates), levels=seq(min(dates), max(dates), by=1));

	myData <- melt(table(dates, values));
	names(myData) <- c("dates", "values", "count");
	myData <- myData[myData$count > 0,];
	
	myplot <- qplot(...) + 
	geom_point(aes(x=dates,y=values, size=count, color=count), data=myData) + 
	geom_text(aes(x=dates,y=values, label=count, size=count/2), data=myData, color="white") +
	scale_size(to = c(5, 20));

	return(myplot);
}

userplot.character <- function(values, dates, ...){
	
	#same as timeplot
	myplot <- timeplot.character(values, dates, ...);
	return(myplot);
	
}

userplot.default <- function(values, dates, ...){
	stop("No userplot has been defined for variables of class: ", class(values))
}


userplot.do <- function(values, dates, ...){
	UseMethod("userplot")	
}

userplot <- function(serverurl, token, campaign_urn, prompt_id, user_id, start_date="2010-01-01", end_date="2020-01-01", privacy_state="both", printurl=FALSE){
	
	if(printurl){
		print(geturl(match.call(expand.dots=T)));
	}
	
	myData <- oh.getdata(serverurl, token, campaign_urn, start_date = start_date, end_date=end_date, prompt_id_list=prompt_id, user_list=user_id, privacy_state=privacy_state);

	fullname <- paste("prompt.id.", prompt_id, sep="");
	plottitle <- paste("userplot: ", user_id, sep="");	
	
	if(nrow(myData) == 0 || sum(!is.na(myData[[fullname]])) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}
	
	#HACK FOR GGPLOT BUG
	if(nrow(myData) == 1){
		return(qplot(0,0,geom="text", label="not enough data to draw a plot.", xlab="", ylab=""));
	}
	###
		
	myplot <- userplot.do(myData[[fullname]], myData$context.utc_timestamp, xlab="", ylab="", main=plottitle)
}


