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

#biplot function
biplot <- function(campaign_urn, prompt_id, prompt2_id, ...){
	
	#secret argument printurl for debugging
	geturl(match.call(expand.dots=T));
	
	#get data for both prompts
	myData <- oh.survey_response.read(campaign_urn, column_list="urn:ohmage:prompt:response", prompt_id_list=unique(c(prompt_id, prompt2_id)), ...);
	myData <- na.omit(myData);
	
	#check for empty plot
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab=prompt_id, ylab=prompt2_id));
	}	
	
	xvarname <- paste("prompt.id.", prompt_id, sep="");
	yvarname <- paste("prompt.id.", prompt2_id, sep="");	
	
	myplot <- biplot.do(myData[[xvarname]], myData[[yvarname]], xlab=prompt_id, ylab=prompt2_id, main="");
}

