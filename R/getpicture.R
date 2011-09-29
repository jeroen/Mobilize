# TODO: Add comment
# 
# Author: jeroen
###############################################################################


getpicture <- function(serverurl, token, campaign_urn, owner, id, ...){
	
	if(is.null(token) | is.null(serverurl)){
		stop("Need to supply both server and valid token.");
	}
	
	assign("SERVERURL", serverurl, "package:Ohmage");
	assign("TOKEN", token, "package:Ohmage");	
	
	myimage <- oh.image.read(campaign_urn, owner, id, ...);
	attr(myimage, "CONTENTTYPE") <- "image/jpeg";
	
	return(myimage);
}
