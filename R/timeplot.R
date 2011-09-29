# TODO: Add comment
# 
# Author: jeroen
###############################################################################

timeplot.POSIXct <- function(values, dates, ...){
	#remove date
	values <- as.numeric(format(values, "%H"));
	myplot <- qplot(dates, values, ...);
	return(myplot);	
}

timeplot.hours_before_now <- function(values, dates, ...){
	#same plot as timestamp but with hours subtracted 
	timeofday <- as.numeric(format(dates, "%H")) - values;
	myplot <- qplot(dates, timeofday, ...);
	return(myplot);	
}


timeplot.multifactor <- function(values, dates, ...){
	newvalues <- as.vector(values);
	newdates <- rep(dates, dim(values));
	timeplot.do(newvalues, newdates, ...);
}

timeplot.numeric <- function(values, dates, ...){
	
	#create dataframe of quantiles
	dates <- as.Date(dates);
	dates <- factor(unclass(dates), levels=seq(min(dates), max(dates), by=1));
	quantiles <- sapply(split(values,dates), quantile, probs=c(0, 0.5, 1), na.rm=T)
	quantiles <- quantiles[!is.na(quantiles[,2]),];

  myData <- as.data.frame(t(quantiles));
  names(myData) <- c("Min", "Mean", "Max");
  myData$dates <- as.Date(row.names(myData));
  
  myplot <- qplot(...) +
     geom_ribbon(aes(x=dates, ymin=Min, ymax=Max), alpha=0.3, data=myData) +
     geom_line(aes(x=dates, y=Mean), size=2, color="blue", data=myData);
     
  return(myplot);
	
}

timeplot.factor <- function(values, dates, ...){
	
	#create dataframe of counts
	dates <- as.Date(dates);
	dates <- factor(unclass(dates), levels=seq(min(dates), max(dates), by=1));
	counts <- sapply(split(values,dates), table);
	myData <- melt(counts);
	
	#cast the datatypes
	names(myData) <- c("factor", "date", "count");	
	myData$date <- as.Date(myData$date);	
	myData$factor <- factor(myData$factor, levels=levels(values), ordered=T);	
	
	#return plot
	myplot <- qplot(date, count, fill=factor, geom="bar", stat="identity", data=myData, ...) +
		scale_fill_hue(breaks = rev(levels(myData$factor)));
	return(myplot);	
}

timeplot.character <- function(values, dates, ...){
	
	#create dataframe of strings
	dates <- as.Date(dates);
	dates <- factor(unclass(dates), levels=seq(min(dates), max(dates), by=1));
	y <- runif(length(dates),0,1);
	angle <- rnorm(length(dates),0,10)
	myData <- data.frame(date=dates, text=values, y=y, angle=angle);
	
	#create plot
	myplot <- qplot(date, y, label=text, angle=angle, geom="text", data=myData, ...)
	return(myplot);
	
}

timeplot.default <- function(values, dates, ...){
	stop("No timeplot has been defined for variables of class: ", class(values))
}


timeplot.do <- function(values, dates, ...){
	UseMethod("timeplot")	
}

#note: PASSING ON ... TO xxxxxplot.do ... has been disabled for now.
timeplot <- function(serverurl, token, campaign_urn, prompt_id, start_date="2010-01-01", end_date="2020-01-01", privacy_state="both", printurl=FALSE){
	
	if(printurl){
		print(geturl(match.call(expand.dots=T)));
	}
	
	myData <- oh.getdata(serverurl, token, campaign_urn, start_date = start_date, end_date=end_date, prompt_id_list=prompt_id, privacy_state=privacy_state);

	fullname <- paste("prompt.id.", prompt_id, sep="");
	plottitle <- paste("timeplot: ", prompt_id, sep="");	
	
	if(nrow(myData) == 0 || sum(!is.na(myData[[fullname]])) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}
	
	# HACK FOR GGPLOT BUG
	if(length(unique(as.Date(myData$context.utc_timestamp))) == 1){
		return(qplot(0,0,geom="text", label="not enough data to draw a timeseries.", xlab="", ylab=""));
	}
	###
	
	myplot <- timeplot.do(myData[[fullname]], myData$context.utc_timestamp, main=plottitle, xlab="", ylab="")
}

