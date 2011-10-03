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
	#if(length(unique(values)) < 8){
	#	values <- factor(values, ordered=T);
	#	distributionplot.do(values, ...);
	#}
	
	myplot <- qplot(values, geom="bar", ...) 
	return(myplot);
}

distributionplot.factor <- function(values, ...){
	myplot <- qplot(values, geom="bar", fill=values, ...);
	if(length(levels(values)) > 7){
		myplot <- myplot + opts(axis.text.x=theme_text(angle=45));
	}	
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

distributionplot <- function(campaign_urn, prompt_id, ...){
	
	#secret argument printurl for debugging	
	geturl(match.call(expand.dots=T));
		
	#get data
	myData <- oh.survey_response.read(campaign_urn=campaign_urn, prompt_id=prompt_id, column_list="urn:ohmage:prompt:response", ...);
	myData <- na.omit(myData);
	fullname <- paste("prompt.id.", prompt_id, sep="");
	
	#check for no data
	if(nrow(myData) == 0 || sum(!is.na(myData[[fullname]])) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	
	
	#draw plot
	plottitle <- paste("distributionplot: ", prompt_id, sep="");	
	myplot <- distributionplot.do(na.omit(myData[[fullname]]), xlab="", ylab="", main=plottitle)
}