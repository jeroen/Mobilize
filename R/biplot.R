# TODO: Add comment
# 
# Author: jeroen
###############################################################################

biplot.numeric <- function(xvar, yvar, xlab, ylab, ...){
	if("factor" %in% class(yvar)){
		#we switch the labels and axes
		myplot <- qplot(yvar, xvar, geom="boxplot", xlab=ylab, ylab=xlab, ...) +  coord_flip();
		print(myplot);
	} else {
		myplot <- qplot(xvar, yvar, geom="point", xlab=xlab, ylab=ylab, ...) + stat_density2d(aes(color = ..level..), geom="density2d")
		return(myplot);
	}

}

biplot.factor <- function(xvar, yvar, ...){
	if("factor" %in% class(yvar)){
		return(biplot.factorfactor(xvar,yvar, ...));
	} else {
		myplot <- qplot(xvar, yvar, geom="boxplot", ...)
		return(myplot);
	}
}

biplot.factorfactor <- function(xvar, yvar, ...){
	#melt data into df
	myData <- melt(table(xvar,yvar));
	myData$xvar <- factor(myData$xvar, levels=levels(xvar), ordered=T);
	myData$yvar <- factor(myData$yvar, levels=levels(yvar), ordered=T);
	myData <- myData[myData$value > 0,];

	#make plot
	myplot <- qplot(...) + 
	geom_point(aes(x=xvar,y=yvar, size=value, color=value), data=myData) + 
	geom_text(aes(x=xvar,y=yvar, label=value, size=value/2), data=myData, color="white") +
	scale_size(to = c(5, 20)); 
	
	#return plot 
	return(myplot);
}

biplot.character <- function(values, dates, ...){
	stop("Biplots can only be made for number and single_choice prompts.")
}


biplot.do <- function(values, dates, ...){
	UseMethod("biplot")	
}
#note: PASSING ON ... TO xxxxxplot.do ... has been disabled for now.
biplot <- function(serverurl, token, campaign_urn, prompt_id, prompt2_id, start_date="2010-01-01", end_date="2020-01-01", privacy_state="both", printurl=FALSE){
	
	if(printurl){
		print(geturl(match.call(expand.dots=T)));
	}
	
	myData <- oh.getdata(serverurl, token, campaign_urn, start_date = start_date, end_date=end_date, privacy_state=privacy_state, prompt_id_list=paste(unique(c(prompt_id, prompt2_id)), collapse=","));
	
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	
	
	xvarname <- paste("prompt.id.", prompt_id, sep="");
	yvarname <- paste("prompt.id.", prompt2_id, sep="");	
	plottitle <- paste("biplot: ", prompt_id, " - ", prompt2_id, sep="");
	
	myplot <- biplot.do(myData[[xvarname]], myData[[yvarname]], xlab=prompt_id, ylab=prompt2_id, main="")
}

