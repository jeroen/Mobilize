# TODO: Add comment
# 
# Author: jeroen
###############################################################################

sinkfile = FALSE;
pdffile = TRUE;
serverurl = 'https://dev3.mobilizingcs.org/app';
username = 'ohmage.jeroen';
password = 'ohmage.jeroen';

library(Mobilize);
mytoken <- oh.login(username, password, serverurl);
campaigns <- oh.campaign.read(output="long");
campaignnames <- names(campaigns$data);
oh.logout();

if(sinkfile) {
	sink("urls.txt", type="output");
	message("printing urls to: ", getwd(), "/urls.txt")
}	

if(pdffile) {
	message("printing plots to: ", getwd(), "/testplots.pdf")
	pdf("test.plots.pdf", width=12, height=8, paper="a4r");
}

cat("TOKEN: ", mytoken, "\n");
for(campaign.urn in campaignnames){
	cat("CAMPAIGN: ", campaign.urn, "\n");
	try(print(responseplot(serverurl, mytoken, campaign.urn, printurl=TRUE)));
	try(print(sharedplot(serverurl, mytoken, campaign.urn, printurl=TRUE)));
	try(print(sharedtimeplot(serverurl, mytoken, campaign.urn, printurl=TRUE)));
	
	campaigndata <- oh.getdata(serverurl, mytoken, campaign.urn);
	allprompts <- grep("prompt.id", names(campaigndata), value=TRUE);
	
	for(thisprompt in allprompts){
		promptname <- gsub("prompt.id.","",thisprompt);
		cat("PROMPT: ", promptname, "\n");
		
		try(print(timeplot(serverurl, mytoken, campaign.urn, promptname, printurl=TRUE)));
		try(print(distributionplot(serverurl, mytoken, campaign.urn, promptname, printurl=TRUE)));
		try(print(userplot(serverurl, mytoken, campaign.urn, promptname, username, printurl=TRUE)));
	}		
}

if(sinkfile) sink();
if(pdffile) dev.off();		
