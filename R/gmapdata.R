# TODO: Add comment
# 
# Author: jeroen
###############################################################################

recordlist <- function(mydataframe){
	L <- list();
	if(nrow(mydataframe) == 0) return(L);
	for(i in 1:nrow(mydataframe)){
		L[[i]] <- lapply(as.list(mydataframe[i,]), as.scalar);
	}
	return(L);
}

#this function is not a plot but generates some data (call through json handler)
gmapdata <- function(serverurl, token, campaign_urn, prompt_id=NULL, ...){
	
	myData <- oh.getdata(serverurl, token, campaign_urn, column_list="urn:ohmage:prompt:response,urn:ohmage:context:location:latitude,urn:ohmage:context:location:longitude,urn:ohmage:user:id,urn:ohmage:context:utc_timestamp,urn:ohmage:survey:id", ...);

  #specify output data
  outputcolumns <- c("context.location.longitude","context.location.latitude","context.utc_timestamp","user.id"); 
  newnames <- c("lng", "lat", "timestamp", "user_id");
  
  #check for a photoprompt
  photoprompts <- which(lapply(myData, attr, "prompt_type") == "photo");
  if(length(photoprompts) > 0){
	mostpictures <- which.min(sapply(lapply(myData[photoprompts], is.na),sum));
	promptname <- names(photoprompts)[mostpictures];

    outputcolumns <- c(outputcolumns, promptname);
    newnames <- c(newnames, "photo");
  }
 
  #add a custom column 
  if(!is.null(prompt_id)){
	  outputcolumns <- c(outputcolumns, paste("prompt.id.",prompt_id,sep=""));   
	  newnames <- c(newnames, ,prompt_id);
 	}
  
  #select rows without missing data
  myData <- myData[outputcolumns];
  #myData <- na.omit(myData);

  #get it in the right format:
  myData[["context.utc_timestamp"]] <- as.character(myData[["context.utc_timestamp"]]);  
  names(myData) <- newnames;

  return(recordlist(myData)); 	
	
}