#load library
library(Mobilize);

#login
serverurl <- 'https://dev3.mobilizingcs.org/app';
mytoken <- oh.login('ohmage.jeroen','ohmage.jeroen',serverurl);

#get data from the server
campaigns <- oh.campaign.read(output="long");
mycampaign <- grep("nack",names(campaigns$data), value=T)[1]
somedata <- oh.survey_response.read(mycampaign);
allprompts <- grep("prompt.id", names(somedata), value=TRUE);
promptnames <- gsub("prompt.id.","", allprompts);
allusers <- unique(unname(unlist(campaigns$data[[mycampaign]]$user_role_campaign)));

#get filtered data, e.g
somedata <- oh.survey_response.read(mycampaign, start_date="2011-06-01", end_date="2011-06-30");
somedata <- oh.survey_response.read(mycampaign, privacy_state="shared");
somedata <- oh.survey_response.read(mycampaign);

#plot call simply passes on parameters to the server
print(responseplot(mycampaign));
print(responseplot(mycampaign, printurl=TRUE));
print(responseplot(mycampaign, start_date="2011-06-01", end_date="2011-06-30", printurl=TRUE));
print(responseplot(mycampaign, privacy_state="shared"));
print(responseplot(mycampaign, privacy_state="private"));
print(responseplot(mycampaign, privacy_state="both")); #default

#to call remotely:
oh.logout();
print(responseplot(mycampaign, serverurl=serverurl, token=mytoken));

#login again cause that's easier
library(Mobilize);
serverurl <- 'https://dev3.mobilizingcs.org/app';
mytoken <- oh.login('ohmage.jeroen','ohmage.jeroen',serverurl);

#sharedplot
print(sharedplot(mycampaign));
print(sharedplot(mycampaign, printurl=TRUE));
print(sharedplot(mycampaign, start_date="2011-06-01", end_date="2011-06-30", printurl=TRUE));
print(sharedplot(mycampaign, privacy_state="shared"));
print(sharedplot(mycampaign, privacy_state="private"));
print(sharedplot(mycampaign, privacy_state="both")); #default

#sharedtimeplot
print(sharedtimeplot(mycampaign, verbose=T));
print(sharedtimeplot(mycampaign, aggregate=30));
print(sharedtimeplot(mycampaign, printurl=TRUE));
print(sharedtimeplot(mycampaign, start_date="2011-06-01", end_date="2011-06-30", printurl=TRUE));
print(sharedtimeplot(mycampaign, privacy_state="shared"));
print(sharedtimeplot(mycampaign, privacy_state="private"));
print(sharedtimeplot(mycampaign, privacy_state="both")); #default

#distributionplots
for(myprompt in promptnames){
	try(print(distributionplot(mycampaign, myprompt, printurl=TRUE)));	
	try(print(distributionplot(mycampaign, myprompt, start_date="2011-06-01", end_date="2011-06-30", printurl=TRUE)));
	try(print(distributionplot(mycampaign, myprompt, privacy_state="shared", printurl=TRUE)));
	try(print(distributionplot(mycampaign, myprompt, start_date="2000-01-01", end_date="2000-01-01", printurl=TRUE)));
}

#timeplots
for(myprompt in promptnames){
	try(print(timeplot(mycampaign, myprompt, printurl=TRUE)));	
	try(print(timeplot(mycampaign, myprompt, start_date="2011-06-01", end_date="2011-06-30", printurl=TRUE, agg=30)));
	try(print(timeplot(mycampaign, myprompt, privacy_state="shared", printurl=TRUE, agg=30)));
	try(print(timeplot(mycampaign, myprompt, start_date="2000-01-01", end_date="2000-01-01", printurl=TRUE, agg=30)));
}

#userplots
for(myprompt in promptnames){
	for(myuser in "ohmage.jeroen"){
		try(print(userplot(mycampaign, myprompt, myuser, printurl=TRUE)));
	}
}

#scatterplots
for(myprompt1 in promptnames){
	for(myprompt2 in promptnames){
		try(print(scatterplot(mycampaign, myprompt1, myprompt2, jiter=FALSE, printurl=TRUE)));
	}
}

#biplots
for(myprompt1 in promptnames){
	for(myprompt2 in promptnames){
		try(print(biplot(mycampaign, myprompt1, myprompt2, printurl=TRUE)));
	}
}

