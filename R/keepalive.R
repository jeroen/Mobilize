# TODO: Add comment
# 
# Author: jeroen
###############################################################################


keepalive <- function(serverurl, token){
	
	if(is.null(token) | is.null(serverurl)){
		stop("Need to supply both server and valid token.");
	}
	
	assign("SERVERURL", serverurl, "package:Ohmage");
	assign("TOKEN", token, "package:Ohmage");	
	
	if(oh.user.read("")$result != "success"){
		stop("Something went wrong...")
	}
	return(list(result="success"));	
}
