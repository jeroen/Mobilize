#bin per aggregate
#used to calculate e.g. mean/min/max over x-day intervals

bin.by.date <- function(dates, values, binwidth=7, FN=quantile, ...){
	bindates <- structure((unclass(dates) %/% binwidth  + 0.5) * binwidth, class="Date")
	quantiles <- sapply(split(values, bindates), quantile, probs=c(0, 0.5, 1), na.rm=T)
	myData <- as.data.frame(t(quantiles));
	myData <- na.omit(myData)
	myData <- cbind(Date=as.Date(row.names(myData)), myData);
	row.names(myData) <- NULL;
	return(myData);
}