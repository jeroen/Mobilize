# TODO: Add comment
# 
# Author: jeroen
###############################################################################

#prepare
library(Mobilize)
oh.logout();

#login
serverurl <- 'https://dev3.mobilizingcs.org/app';
mytoken <- oh.login('ohmage.jeroen','ohmage.jeroen', serverurl);

#get some data
CHIPTS <- "urn:campaign:andwellness:chipts:07272011";
data.CHIPTS <- oh.survey_response.read(CHIPTS);


#SUPER CAMPAIGN
CAMPAIGN <- "urn:campaign:ca:ucla:Mobilize:July:2011:SuperCampaign";
USERNAME <- "ohmage.jeroen"

#Get some data
data.SUPER <- oh.survey_response.read(CAMPAIGN);

pdf("SUPER.plots.pdf", paper="A4r", width=12, height=8);
#Print Survey Level Plots
print(responseplot(serverurl, mytoken, CAMPAIGN, printurl=TRUE));
print(sharedplot(serverurl, mytoken, CAMPAIGN, printurl=TRUE));
print(sharedtimeplot(serverurl, mytoken, CAMPAIGN, printurl=TRUE));

#Print All Prompt Plots For Every Type
allprompts <- grep("prompt.id", names(data.SUPER), value=TRUE);
for(thisprompt in allprompts){
	promptname <- gsub("prompt.id.","",thisprompt);
	cat("PROMPT: ", promptname, "\n");	
	try(print(timeplot(serverurl, mytoken, CAMPAIGN, promptname, printurl=TRUE)));
}	

for(thisprompt in allprompts){
	promptname <- gsub("prompt.id.","",thisprompt);
	cat("PROMPT: ", promptname, "\n");	
	try(print(distributionplot(serverurl, mytoken, CAMPAIGN, promptname, printurl=TRUE)));
}	

for(thisprompt in allprompts){
	promptname <- gsub("prompt.id.","",thisprompt);
	cat("PROMPT: ", promptname, "\n");	
	try(print(userplot(serverurl, mytoken, CAMPAIGN, promptname, USERNAME, printurl=TRUE)));
}	
dev.off();


#SUPER CAMPAIGN
CAMPAIGN <- "urn:campaign:andwellness:chipts:07272011";
CAMPAIGNDATA <- oh.survey_response.read(CAMPAIGN);
USERNAME <- "ohmage.jeroen"

pdf("CHIPTS.plots.pdf", paper="A4r", width=12, height=8);
#Print Survey Level Plots
print(responseplot(serverurl, mytoken, CAMPAIGN, printurl=TRUE));
print(sharedplot(serverurl, mytoken, CAMPAIGN, printurl=TRUE));
print(sharedtimeplot(serverurl, mytoken, CAMPAIGN, printurl=TRUE));

#Print All Prompt Plots For Every Type
allprompts <- grep("prompt.id", names(CAMPAIGNDATA), value=TRUE);
for(thisprompt in allprompts){
	promptname <- gsub("prompt.id.","",thisprompt);
	cat("PROMPT: ", promptname, "\n");	
	try(print(timeplot(serverurl, mytoken, CAMPAIGN, promptname, printurl=TRUE)));
}	

for(thisprompt in allprompts){
	promptname <- gsub("prompt.id.","",thisprompt);
	cat("PROMPT: ", promptname, "\n");	
	try(print(distributionplot(serverurl, mytoken, CAMPAIGN, promptname, printurl=TRUE)));
}	

for(thisprompt in allprompts){
	promptname <- gsub("prompt.id.","",thisprompt);
	cat("PROMPT: ", promptname, "\n");	
	try(print(userplot(serverurl, mytoken, CAMPAIGN, promptname, USERNAME, printurl=TRUE)));
}	
dev.off();

#problems
user.data <- oh.getdata(serverurl, mytoken, CAMPAIGN, prompt_id_list="photoDiaryText");
