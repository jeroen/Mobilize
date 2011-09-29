distributionplot.POSIXct <- function(values, ...){
	# remove date
	# values <- strptime(format(values, "%H:%M:%S"), format="%H:%M:%S");
	myplot <- qplot(values, ...);
	return(myplot);	
}

distributionplot.hours_before_now <- function(values, ...){
	myfactor <- as.vector(values);
	distributionplot.do(myfactor, ...);	
}

distributionplot.multifactor <- function(values, ...){
	myfactor <- as.vector(values);
	distributionplot.do(myfactor, ...);
}

distributionplot.numeric <- function(values, ...){
	
	#exception if there are only a couple of unique values:
	if(length(unique(values)) < 8){
		values <- factor(values, ordered=T);
		distributionplot.do(values, ...);
	}
	
	myplot <- qplot(values, geom="bar", ...) 
	return(myplot);
}

distributionplot.factor <- function(values, ...){
	myplot <- qplot(values, geom="bar", fill=values, ...);
	return(myplot);
}

distributionplot.character <- function(values, ...){
	#some string manipulation
	bigstring <- paste(values, collapse=" ");
	bigstring <- gsub("[\f\t.,;:`'\\\"\\(\\)<>]+", " ", bigstring);
	allwords <- tolower(strsplit(bigstring, " +")[[1]])
	
	#count, sort, head
	cloud <- melt(head(sort(table(allwords), decr=T), 100))
	if(length(allwords) == 1){
		words <- names(cloud);
		wordcount <- unname(cloud);
	} else {
		words <- cloud[[1]];
		wordcount <- cloud[[2]];
	}
	
	#make the plot
	qplot(x=runif(length(words)), y=runif(length(words)), ..., geom="text", label=words, size=wordcount, color=wordcount) +
	scale_size(to = c(6, 12)) 		
	
}

distributionplot.do <- function(values, ...){
	UseMethod("distributionplot");
}

distributionplot <- function(serverurl, token, campaign_urn, prompt_id, start_date="2010-01-01", end_date="2020-01-01", privacy_state="both", printurl=FALSE, ...){
	
	if(printurl){
		print(geturl(match.call(expand.dots=T)));
	}
	
	myData <- oh.getdata(serverurl, token, campaign_urn, start_date = start_date, end_date=end_date, privacy_state=privacy_state, prompt_id_list=prompt_id);

	fullname <- paste("prompt.id.", prompt_id, sep="");
	plottitle <- paste("distributionplot: ", prompt_id, sep="");	
	
	if(nrow(myData) == 0 || sum(!is.na(myData[[fullname]])) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	

	myplot <- distributionplot.do(myData[[fullname]], xlab="", ylab="", main=plottitle, ...)
}