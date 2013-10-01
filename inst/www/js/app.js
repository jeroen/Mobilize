$(function() {
  
  var campaign_urn;
  var campaigndata = {};
  
  function loadcampaign(){
    if(!campaign_urn) return;
    if(campaigndata[campaign_urn]){
      populate(campaigndata[campaign_urn]);
    } else {
      mydata = [];
      oh.campaign.read(campaign_urn, "xml", function(res){
        var xml = $(jQuery.parseXML(res));
        $.each($("survey", xml), function(i, survey){
          var promptdata = [];
          var prompts = $(">contentList>prompt", survey);        
          $.each(prompts, function(i, prompt){
            promptdata.push({
              id : $(">id",prompt).text(),
              promptType : $(">promptType", prompt).text(),
              promptlabel : $(">displayLabel", prompt).text()
            });
          });
          mydata.push({
            id : $(">id", survey).text(),
            title : $(">title", survey).text(),
            prompts : promptdata
          })
        });
        campaigndata[campaign_urn] = mydata;
        
        //recursive in case user changed selection in the mean time
        loadcampaign();
      });
    }
  }
  
  function populate(mydata){
    console.log(mydata)
  }
  
  $("#campaignfield").change(function(){
    campaign_urn = $("#campaignfield option:selected").val();
    loadcampaign()
  })
  
  //init page
	oh.ping(function(){
		oh.user.whoami(function(x){
      $("#username").text(x);
      
      //populate campaign dropdown
			oh.user.info(function(data){
        $.each(data[x].campaigns, function(urn, title){
          $("#campaignfield").append($("<option>").text(title).attr("value", urn));
        });
			});
		});
	});
});