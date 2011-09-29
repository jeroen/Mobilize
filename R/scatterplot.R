# TODO: Add comment
# 
# Author: jeroen
###############################################################################

#note: PASSING ON ... TO xxxxxplot.do ... has been disabled for now.
scatterplot <- function(serverurl, token, campaign_urn, prompt_id, prompt2_id, start_date="2010-01-01", end_date="2020-01-01", privacy_state="both", printurl=FALSE){
	
	if(printurl){
		print(geturl(match.call(expand.dots=T)));
	}
	
	myData <- oh.getdata(serverurl, token, campaign_urn, start_date = start_date, end_date=end_date, privacy_state=privacy_state, prompt_id_list=paste(unique(c(prompt_id, prompt2_id)), collapse=","));
	
	if(nrow(myData) == 0){
		return(qplot(0,0,geom="text", label="request returned no data.", xlab="", ylab=""));
	}	
	
	xvarname <- paste("prompt.id.", prompt_id, sep="");
	yvarname <- paste("prompt.id.", prompt2_id, sep="");	
	plottitle <- paste("scatterplot: ", prompt_id, " - ", prompt2_id, sep="");
	
	myplot <- qplot(myData[[xvarname]], myData[[yvarname]], xlab=prompt_id, ylab=prompt2_id, main="", geom="point")
}
