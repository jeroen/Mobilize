$(function() {
  
  var campaign_urn;
  var campaigndata = {};
  var today = new Date();
  var serverurl = location.protocol + "//" + location.host + "/app"
  
  function loadcampaign(){
    $("#surveyfield").empty();
    if(!campaign_urn) {
      $("#campaigngroup").addClass("has-error");
      return;
    }
    if(campaigndata[campaign_urn]){
      populate(campaigndata[campaign_urn]);
    } else {
      var mydata = [];
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
        
        //recursive in case user changed selection in the mean time        
        campaigndata[campaign_urn] = mydata;
        loadcampaign();
      });
    }
  }
  
  function populate(mydata){
    $.each(mydata, function(i, survey){
      $("#surveyfield").append($("<option>").val(survey.id).text(survey.title));
    });
  }
  
  function updateplot(){
    if(!campaign_urn) {
      $("#campaigngroup").addClass("has-error");
      return;
    }
    
    $("#plotbutton").attr("disabled", "disabled");
    var req = $("#plotdiv").r_fun_plot("responseplot", {
      campaign_urn : campaign_urn,
      serverurl : serverurl,
      token : $.cookie("auth_token"),
      start_date : $("#fromfield").val(),
      end_date : $("#tofield").val()
    }).fail(function(){
      alert(req.responseText);
    }).always(function(){
      $("#plotbutton").removeAttr("disabled")
    });    
  }
  
  $("#campaignfield").change(function(){
    campaign_urn = $("#campaignfield option:selected").val();
    if(campaign_urn){
      $("#campaigngroup").removeClass("has-error");
    }
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
        $("#campaignfield").val("");
			});
		});
	});
  
  $("#paramform .input-append.date").datepicker({format: "yyyy-mm-dd"});
  $("#tofield").val(today.getFullYear() + "-" + zeroFill(today.getMonth()+1, 2) + "-" + zeroFill(today.getDate(),2)); 
  $("#plotdiv").resizable();
  $("#plotbutton").on("click", updateplot);
});

function zeroFill( number, width ) {
  width -= number.toString().length;
  if ( width > 0 ) {
    return new Array( width + (/\./.test( number ) ? 2 : 1) ).join( '0' ) + number;
  }
  return number + ""; // always return a string
}