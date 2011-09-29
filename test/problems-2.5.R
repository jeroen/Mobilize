# TODO: Add comment
# 
# Author: jeroen
###############################################################################


library(Mobilize);
serverurl = 'https://dev3.mobilizingcs.org/app';
username = 'ohmage.jeroen';
password = 'ohmage.jeroen';
mytoken <- oh.login(username, password, serverurl);
campaigns <- oh.campaign.read(output="long");
campaignnames <- names(campaigns$data);
oh.logout();
CHIPTS <- 'urn:andwellness:chipts'

myData = oh.getdata(serverurl, mytoken, CHIPTS, column_list="urn:ohmage:user:id,urn:ohmage:context:utc_timestamp,urn:ohmage:survey:id");
print(responseplot(serverurl, mytoken, CHIPTS, printurl=TRUE))


print(userplot(serverurl, mytoken, 'urn:campaign:ca:ucla:Mobilize:May:2011:Snack', prompt="SnackImage", user="ohmage.jeroen"));