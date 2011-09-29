# TODO: Add comment
# 
# Author: jeroen
###############################################################################


library(Mobilize);
serverurl <- 'https://dev3.mobilizingcs.org/app';
mytoken <- oh.login('ohmage.jeroen','ohmage.jeroen',serverurl);
campaigns <- oh.campaign.read(output="long");

#extract some campaign and some user
CS219 <- names(campaigns$data)[1];
Advertisement <- grep("Advertisement",names(campaigns$data), value=T)[1]
Sleep <- grep("Sleep",names(campaigns$data), value=T)[1]
Snack <- grep("Snack",names(campaigns$data), value=T)[1]

#logout to simulate stateless remote call
oh.logout();

#get some data
CS219.data <- oh.getdata(serverurl, mytoken, CS219);
Advertisement.data <- oh.getdata(serverurl, mytoken, Advertisement);
Sleep.data <- oh.getdata(serverurl, mytoken, Sleep);
Snack.data <- oh.getdata(serverurl, mytoken, Snack);

#test gmapdata
geo.data <- gmapdata(serverurl, mytoken, Snack)

#test to get just 1 prompt:
waketime.data <- oh.getdata(serverurl, mytoken, Sleep, prompt_id_list = "WakeupTime");
responses.data <- oh.getdata(serverurl, mytoken, Snack, column_list="urn:ohmage:user:id,urn:ohmage:context:utc_timestamp,urn:ohmage:survey:id");
user.data <- oh.getdata(serverurl, mytoken, Sleep, prompt_id_list="WakeupTime", user_list="ohmage.bad");

#test the RPC function
myplot <- timeplot(serverurl, mytoken, Advertisement, "Feeling");
myplot <- userplot(serverurl, mytoken, Advertisement, "Feeling", "ohmage.baa");
myplot <- userplot(serverurl, mytoken, Sleep, "WakeupTime", "ohmage.bad");

#test some biplots
myplot <- biplot(serverurl, mytoken, Sleep, "HowTired", "Concentration");
myplot <- biplot(serverurl, mytoken, Sleep, "AttentionGame", "Concentration");
myplot <- biplot(serverurl, mytoken, Sleep, "HowTired", "AttentionGame");

############ # # test all plots for all 3 campaigns # # ########
pdf("test.plots.pdf", width=12, height=8, paper="a4r");
sink("urls.txt")

#responseplots
print(responseplot(serverurl, mytoken, Advertisement, printurl=TRUE));
print(responseplot(serverurl, mytoken, Sleep, printurl=TRUE));
print(responseplot(serverurl, mytoken, Snack, printurl=TRUE));

#test plots for Advertisement
for(thisprompt in grep("prompt.id", names(Advertisement.data), value=T)){
	promptname <- gsub("prompt.id.","",thisprompt);
	
	#timeplot
	myplot <- timeplot(serverurl, mytoken, Advertisement, promptname, printurl=TRUE);
	print(myplot);
	
	#distributionplot
	myplot <- distributionplot(serverurl, mytoken, Advertisement, promptname, printurl=TRUE);
	print(myplot);	
	
	#userplot
	myplot <- userplot(serverurl, mytoken, Advertisement, promptname, "ohmage.baa", printurl=TRUE);
	print(myplot);

}
#test plots for Sleep
for(thisprompt in grep("prompt.id", names(Sleep.data), value=T)){
	promptname <- gsub("prompt.id.","",thisprompt);
	
	#timeplot
	myplot <- timeplot(serverurl, mytoken, Sleep, promptname, printurl=TRUE);
	print(myplot);
	
	#distributionplot
	myplot <- distributionplot(serverurl, mytoken, Sleep, promptname, printurl=TRUE);
	print(myplot);	
	
	#userplot
	myplot <- userplot(serverurl, mytoken, Sleep, promptname, "ohmage.baa", printurl=TRUE);
	print(myplot);	
	
}
#test plots for Snack
for(thisprompt in grep("prompt.id", names(Snack.data), value=T)){
	promptname <- gsub("prompt.id.","",thisprompt);

	#timeplot
	myplot <- timeplot(serverurl, mytoken, Snack, promptname, printurl=TRUE);
	print(myplot);
	
	#distributionplot
	myplot <- distributionplot(serverurl, mytoken, Snack, promptname, printurl=TRUE);
	print(myplot);		
	
	#userplot
	myplot <- userplot(serverurl, mytoken, Snack, promptname, "ohmage.baa", printurl=TRUE);
	print(myplot);	

}
sink();
dev.off();
#############################################################

