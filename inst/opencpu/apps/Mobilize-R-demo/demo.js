//SOME EXTJS STUFF

Ext.Loader.setConfig({enabled: true});

Ext.require([
    'Ext.container.Viewport',
    'Ext.layout.*',
    'Ext.form.*',
    'Ext.data.*',
    'Ext.tree.*',
    'Ext.selection.*',
    'Ext.tab.Panel',
    'Ext.window.*'   
]);


Ext.onReady(function(){

	var cp = new Ext.state.CookieProvider({
		expires: new Date(new Date().getTime()+(1000*60*60*24*365)) //365 days
	});
	Ext.state.Manager.setProvider(cp);


	document.getElementById("picturelinks").style.display = "none";

	//LIGHTBOX2
	
	function fireEvent(obj,evt){
		var fireOnThis = obj;
		if( document.createEvent ) {
			var evObj = document.createEvent('MouseEvents');
			evObj.initEvent( evt, true, false );
			fireOnThis.dispatchEvent(evObj);
		} else if( document.createEventObject ) {
			fireOnThis.fireEvent('on'+evt);
		}
	}	

	function showPicture(user_id, photo, campaign_urn){
	
		if(photo.length != 36){
			alert("No photo available. Item: " + photo);
			return;
		}
	
		url = "/R/Mobilize/getpicture/file?server="+SERVER+ "&token="+ TOKEN + "&campaign='" + campaign_urn + "'&owner='" + user_id + "'&id='" + photo + "'";
		
		var newlink = document.createElement('a');
		newlink.setAttribute('href',url);
		newlink.setAttribute('rel','lightbox');
		newlink.setAttribute('title', 'Picture by user '+ user_id);
		newlink.appendChild(document.createTextNode('link'));
		document.getElementById('picturelinks').appendChild(newlink);

		document.lightbox.start.call(document.lightbox,newlink);

	}	
	
	//GOOGLE MAPS
	mapwin = {
            xtype: 'gmappanel',
			id: 'gmappanel',
            zoomLevel: 10,
            border: false,
            gmapType: 'map',
            mapConfOpts: ['enableScrollWheelZoom','enableDoubleClickZoom','enableDragging'],
            mapControls: ['GSmallMapControl','GMapTypeControl','NonExistantControl'],
            setCenter: {
                geoCodeAddr: 'UCLA, Los Angeles',
                marker: {title: 'Los Angeles'}
            },
            markers: []
        };
		
	var makehandler = function(user_id, photo, campaign_urn){
		return function(){showPicture(user_id, photo, campaign_urn)}
	}
		
    var markerListeners = {
    	click: function(e){
			for(k in e){
				alert(k+ ": " + e[k].toSource());
			}
			alert(e.toSource());
			
			if(e.photo == null){
				alert("No photo available for this response.");
				return;
			}
			showPicture(e.user_id, e.photo);
		}
	};		


	//CAMPAIGN DATA
	
	var TOKEN;
	var SERVER;
	var USERNAME;
	var PASSWORD;
	var CAMPAIGNS;
	
	var downloadPlot = function(){
		plotfun = treepanel.getSelectionModel().getLastSelected().get('id');
		
		if(this.format=="PDF") {
			var output = "pdf";
		} else {
			var output = "png";
		}		
		
		url = "/R/call/Mobilize/" + plotfun + "/" + output + "?token=" + TOKEN + "&server=" + SERVER;
		
		plotargs = plotarguments[plotfun];
		for(var i = 0; i < plotargs.length; i++){
			if(!Ext.getCmp(plotargs[i] + '_field').validate()) return;
			
			if(Ext.getCmp(plotargs[i] + '_field').xtype == "datefield"){
				url = url + "&" + plotargs[i] + "='" + Ext.getCmp(plotargs[i] + '_field').getRawValue() + "'";
			} else if(Ext.getCmp(plotargs[i] + '_field').xtype == "numberfield"){
				url = url + "&" + plotargs[i] + "=" + Ext.getCmp(plotargs[i] + '_field').getValue();
			} else { 
				url = url + "&" + plotargs[i] + "='" + Ext.getCmp(plotargs[i] + '_field').getValue() + "'";
			}			
		}
		
		if(plotfun == "mapplot"){
			//clear old markers
			Ext.getCmp('gmappanel').getMap().clearOverlays();
			newMask = new Ext.LoadMask(Ext.getCmp('drawbutton'), {msg:"Please wait..."});
			newMask.show();
			Ext.Ajax.request({
				method: 'GET',
				url: '/R/call/Mobilize/gmapdata/json',
				disableCaching: false,
				params: {
					token: TOKEN,
					server: SERVER,
					campaign: "'" + Ext.getCmp('campaign_urn_field').getValue() + "'",
					"!digits": 8 
				},
				success: function(response){
					newMask.hide();
					var text = response.responseText;
					var gmapdata = Ext.decode(text);
					for(var i = 0; i < gmapdata.length; i++){
						var photo = gmapdata[i].photo;
						var user_id = gmapdata[i].user_id;
						var campaign_urn = Ext.getCmp('campaign_urn_field').getValue();
						
						if(photo != null){
							gmapdata[i].listeners = {click: makehandler(user_id, photo, campaign_urn)}
						} else {
							gmapdata[i].listeners = {click: function(){alert('No photo available for this response.')}}
						}
					}
					Ext.getCmp('gmappanel').addMarkers(gmapdata);					
				},
				failure: function(){
					alert('failure getting geo data');
					newMask.hide();
				}
			});
			return;
		}
		
		if(this.format == "PDF"){
			window.open(url);
			return;
		}		
		
		plotwidth = Ext.getCmp('contentpanel').getEl().getWidth();
		plotheight = Ext.getCmp('contentpanel').getEl().getHeight() - 35; //tbar is 32 pix.
		url = url + "&!width=" + plotwidth + "&!height=" + plotheight;
		
		Ext.getCmp('plotcard').update('<img src="' + url + '"> <br /><br /> Generating image... Please wait...');			
	}
	
	var downloadData = function(){
		if(!Ext.getCmp('campaign_urn_field').validate()) return;
		
		url = "/R/call/Ohmage/oh.survey_response.read/csv?token=" + TOKEN + "&server=" + SERVER +"&campaign_urn='" + Ext.getCmp('campaign_urn_field').getValue() + "'"; 
		
		window.open(url);
	}
	
	var getCampaignData = function(){
	    Ext.Ajax.request({
	        url: '/R/call/Mobilize/campaigndata/json',
	        method: 'GET',
	        disableCaching: false,
	        params: {
	    		token: TOKEN,
	            server: SERVER
	        },
	        success: function(response){
	            var text = response.responseText;
	            CAMPAIGNS = Ext.decode(text);
	            
	            var campaignstore = Ext.getStore('campaignstore');
	            campaignstore.removeAll();
	            
	            for(campaignurn in CAMPAIGNS.data){
	            	campaignstore.add({"campaign_urn": campaignurn, "campaign_name":CAMPAIGNS.data[campaignurn].name});
	            }
				
				Ext.myMask.hide();
				Ext.getCmp('contentpanel').getLayout().setActiveItem('mapcard');
				Ext.getCmp('gmappanel').getMap().clearOverlays();
				
				Ext.interval = setInterval('Ext.keepalive()', 5*60*1000);
	        },
	        failure: function(response){
				Ext.myMask.hide();			
	        	alert(response.responseText);
	        }
	    });
	};
	
	var populatePrompts = function(campaignID){
	
		Ext.getCmp('gmappanel').getMap().clearOverlays();
	
		Ext.getCmp('prompt_id_field').reset();
		Ext.getCmp('prompt2_id_field').reset();
		Ext.getCmp('user_id_field').reset();
		
		var promptIDs = CAMPAIGNS.data[campaignID].promptIDs;
		var promptTypes = CAMPAIGNS.data[campaignID].promptTypes;
		
        var promptstore = Ext.getStore('promptstore');
        promptstore.removeAll();
        
        for(var i = 0; i < promptIDs.length; i++){
        	promptstore.add({"prompt_id": promptIDs[i], "promptname": promptIDs[i] + " (" + promptTypes[i] +")"});
        }
		
		var participants = CAMPAIGNS.data[campaignID].user_role_campaign.participant;
		var usernamestore = Ext.getStore('usernamestore');
		usernamestore.removeAll();
		
        for(var i = 0; i < participants.length; i++){
        	usernamestore.add({"username": participants[i]});
        }		
		
	}
	
	var campaigns = Ext.create('Ext.data.Store', {
	    fields: ['campaign_urn', 'campaign_name'],
	    storeId: 'campaignstore',
	    data : [
	    ]
	});
	
	var usernames = Ext.create('Ext.data.Store', {
	    fields: ['username'],
	    storeId: 'usernamestore',
	    data : [
	    ]
	});
	
	var prompts = Ext.create('Ext.data.Store', {
	    fields: ['prompt_id', 'promptname'],
	    storeId: 'promptstore',	    
	    data : [
	    ]
	});
	
	var plotarguments = {
		"responseplot": ["start_date", "end_date", "campaign_urn", "privacy_state", "aggregate"],
		"timeplot" : ["start_date", "end_date", "campaign_urn","prompt_id", "privacy_state", "aggregate"],
		"sharedplot" : ["start_date", "end_date", "campaign_urn"],
		"sharedtimeplot" : ["start_date", "end_date", "campaign_urn", "aggregate"],		
		"distributionplot" : ["start_date", "end_date", "campaign_urn","prompt_id", "privacy_state"],	
		"userplot" : ["start_date", "end_date", "campaign_urn","prompt_id", "user_id", "privacy_state"],
		"mapplot" : ["campaign_urn"],
		"picturemap" : ["start_date", "end_date", "campaign_urn", "prompt_id", "privacy_state"],
		"biplot" : ["start_date", "end_date", "campaign_urn","prompt_id", "prompt2_id", "privacy_state"],
		"scatterplot" : ["start_date", "end_date", "campaign_urn","prompt_id", "prompt2_id", "privacy_state"]
	};
	
	var enableplot = function(type){
		plotproperties = plotarguments[type];
		for(i = 0; i < plotproperties.length; i++){
			Ext.getCmp(plotproperties[i] + "_field").enable();
		}		
		
		if(type == "mapplot"){
			Ext.getCmp('contentpanel').getLayout().setActiveItem('mapcard');
			Ext.getCmp('pdfbutton').disable();
		} else {
			Ext.getCmp('contentpanel').getLayout().setActiveItem('plotcard');
			Ext.getCmp('pdfbutton').enable();
		}
	};	
	
	//BUILD LAYOUT
	var detailEl;
	
	var constrainedWin;

	Ext.logout = function(){
		Ext.getCmp('plotsettingsform').getForm().reset();
		Ext.getCmp('plotcard').update('');
		Ext.getCmp('contentpanel').getLayout().setActiveItem('plotcard');
		Ext.getCmp('plottoolpanel').collapse();
		Ext.win2.show();
		Ext.getCmp('logoutbutton').disable();
		clearInterval(Ext.interval);
	}

	
	var contentpanel = {
	    id: 'contentpanel',
	    border: true,
	    region: 'center',
	    layout: 'card',
	    margins: '2 2 5 0',
	    activeItem: 'plotcard',
	    items: [{
	        id: 'plotcard',
	        layout: 'fit',
	        border: false
	    },{
	        id: 'mapcard',
	        layout: 'fit',
	        border: false,
	        items: mapwin
	    }],
	    tbar: {
	    	id: 'header', 
	    	items:['<h1>Mobilize R Plot Explorer</h1>', '->', '-', {xtype: 'button', id: 'logoutbutton', handler: Ext.logout, disabled: true, text:'Logout', iconCls:'logout32', height: 32, width: 100}]
	    }
	};
	
	var store = Ext.create('Ext.data.TreeStore', {
	    root: {
	        expanded: true
	    },
	    proxy: {
	        type: 'ajax',
	        url: 'tree-data.json'
	    }
	});
	
	var treepanel = Ext.create('Ext.tree.Panel', {
	    id: 'treepanel',
	    stateful: false,
	    //title: 'Sample Plots',
	    region:'center',
	    split: true,
	    margins: '2 0 5 5',    
	    animate: false,
	    rootVisible: false,
	    autoScroll: true,
	    store: store
	});
	
	//Assign the changeLayout function to be called on tree node click.
	treepanel.getSelectionModel().on('select', function(selModel, record) {
		var myitems = Ext.getCmp('plotsettingsfieldset').items;
		
		for (i = 0; i < myitems.getCount(); i++){
			if(myitems.getAt(i).id != 'campaign_urn_field' && myitems.getAt(i).id != 'start_date_field' && myitems.getAt(i).id != 'end_date_field') myitems.getAt(i).reset();
			myitems.getAt(i).disable();	
		}
		
		if (record.get('leaf')) {
	    	enableplot(record.getId());
			Ext.getCmp('pdfbutton').enable();
			Ext.getCmp('drawbutton').enable();
			Ext.getCmp('csvbutton').enable();
	    } else {
			Ext.getCmp('pdfbutton').disable();
			Ext.getCmp('drawbutton').disable();
			Ext.getCmp('csvbutton').disable();
		}
	});
	
	plotsettings = {
		xtype: 'form',
		frame: true,
		id: 'plotsettingsform',
		region: 'south',
	    margins: '2 0 5 5',   
	    buttons: [{text:'Draw Plot', iconCls: 'draw16', id: 'drawbutton', disabled: true, handler: downloadPlot}, {text:'Get PDF', iconCls: 'pdf16', format:"PDF", id:'pdfbutton', disabled: true, handler: downloadPlot}, {text: 'Get Data', iconCls: 'csv16', id: 'csvbutton', disabled: true, handler:downloadData}],
	    items: [
	            {
	            	xtype: "fieldset",
	            	id: 'plotsettingsfieldset',
	            	title: "data settings",
	            	collapsible: true,
	            	defaults: {
	            		size: 28,
	            		msgTarget: 'under',
	            		xtype: 'combo',
	            		disabled: true
	            	},
	            	items:[
			            { 
			            	fieldLabel: 'Campaign',
							allowBlank: false,
			            	id: 'campaign_urn_field',
			            	store: campaigns,
			            	queryMode: 'local',
			            	forceSelection: true,
			            	displayField: 'campaign_name',
			            	valueField: 'campaign_urn',
			            	listeners: {
			            		"select": function(field, selection) {populatePrompts(selection[0].get('campaign_urn'));}			            	
			            	}
			            },
			            { 
			            	fieldLabel: 'Prompt',
							allowBlank: false,
			            	id: 'prompt_id_field',
			            	store: prompts,
			            	queryMode: 'local',
			            	forceSelection: true,
			            	displayField: 'promptname',
			            	valueField: 'prompt_id'
			            },  
			            { 
			            	fieldLabel: 'Prompt2',
							allowBlank: false,
			            	id: 'prompt2_id_field',
			            	store: prompts,
			            	queryMode: 'local',
			            	forceSelection: true,
			            	displayField: 'promptname',
			            	valueField: 'prompt_id'
			            },			            
			            { 
			            	fieldLabel: 'Participant',
							allowBlank: false,
			            	id: 'user_id_field',
			            	store: usernames,
			            	queryMode: 'local',
			            	forceSelection: true,
			            	displayField: 'username',
			            	valueField: 'username'
			            },
			            {
			            	xtype: 'datefield',
			            	fieldLabel: 'From',
			            	name: 'start_date',
			            	id: 'start_date_field',
			            	format: 'Y-m-d',
        					value: '2011-01-01'
			            	
			            },
			            {
			            	xtype: 'datefield',
			            	fieldLabel: 'To',
			            	name: 'end_date',
			            	id: 'end_date_field',
			            	format: 'Y-m-d',
        					value: new Date(new Date().setDate(new Date().getDate()+1)) //today + 1 = tomorrow	            	
			            },
			            {
			            	xtype: 'numberfield',
			            	fieldLabel: 'Aggregate (days)',
			            	name: 'aggregate',
			            	id: 'aggregate_field',
			            	minValue: 1,
			            	maxValue: 365,
        					value: 7 //today + 1 = tomorrow	            	
			            },
						{
			                xtype: 'combo',
			                fieldLabel: 'Privacy',
			                name: 'privacy_state',
			                allowBlank: false,
			                forceSelection: true,
			                id: 'privacy_state_field',
			                store: {
			                    fields: ['privacy_state'],
			                    data: [
			                    	{privacy_state: 'shared'},
			                    	{privacy_state: 'private'},
			                    	{privacy_state: 'both'}
			                    ]
			                },
			                value: 'both',
			                displayField: 'privacy_state',
			                valueField: 'privacy_state'
			            }
			       ]
	          }
	    ],
	    animate: false	
	}
	
	//R plotting tool
	plottool = {
		title: "Plot settings",
		id: 'plottoolpanel',
		stateful: false,
		layout: 'border',
		region: 'east',
		width: 360,
		collapsible: true,
		collapsed: true,
		animCollapse: false,		
		border: false,
		items: [treepanel, plotsettings]
	}
	
    Ext.create('Ext.Viewport', {
        layout: 'border',
        id: 'viewport',
        title: 'Mobilize Demo Plots',
        items: [
                //titlepanel,
                contentpanel,
                plottool
        ],
        renderTo: Ext.getBody()
    });
	
	function authenticate(){
		
		Ext.win2.hide();
		Ext.getCmp('logoutbutton').enable();
		Ext.myMask = new Ext.LoadMask('contentpanel', {msg:"Loading data. Please wait..."});
	    Ext.myMask.show();
		
	    Ext.Ajax.request({
	        url: '/R/call/Ohmage/oh.login/json',
	        method: 'GET',
	        disableCaching: false,
	        params: {
	            user: USERNAME,
	            password: PASSWORD,
	            server: SERVER,
				"!seed": Math.floor(Math.random()*99999999)
	        },
	        success: function(response){
	            var text = response.responseText;
	            TOKEN = "'" + Ext.decode(text)[0] + "'";
	            getCampaignData();
				Ext.getCmp('plottoolpanel').expand();   			
	        },
	        failure: function(response){
				Ext.myMask.hide();
				Ext.win2.show();
				Ext.getCmp('logoutbutton').disable();
	        	alert(response.responseText);
	        }
	    });
	}
	
	Ext.keepalive = function(){
	    Ext.Ajax.request({
	        url: '/R/call/Mobilize/keepalive/json',
	        method: 'GET',
	        disableCaching: false,
	        params: {
				token: TOKEN,
				server: SERVER,
				"!seed": Math.floor(Math.random()*99999999)
	        },
	        success: function(response){
	        },
	        failure: function(response){
				alert("something went wrong when trying to keep alive the session.");
	        }
	    });	
	}
	
	Ext.win2 = Ext.create('widget.window', {
	    height: 180,
	    width: 400,
	    layout: 'fit',
	    closeAction: 'hide',
	    title: 'Authenticate',
	    closable: false,
	    resizable: false,
	    draggable : false,
	    border: false,
	    items: {
	        xtype: 'fieldset',
	        defaultType: 'textfield',
	        defaults:{
	            width: 365,
				stateful: true,
        		stateEvents: ['blur'],
        		getState: function() {
		            return {
		                value: this.getRawValue()
		            };
  			    },
    		    applyState: function(state) {
    		    	this.setRawValue(state.value);
      		  	}	            
	        },
	        items: [
	            {
	                fieldLabel: 'Username',
	                name: 'username',
	                id: 'username_field',
	                //value: 'ohmage.ooms',
	                allowBlank:false
	            },{
	                fieldLabel: 'Password',
	                name: 'password',
	                id: 'password_field',
	                inputType: 'password',
	                //value: 'vohohdai.g',
	                allowBlank: false
	            },{
	                xtype: 'combo',
	                fieldLabel: 'Ohmage Server',
	                id: 'server_field',
	                store: {
	                    fields: ['server'],
	                    data: [
	                    	{server: 'https://dev.andwellness.org/app'},
	                    	{server: 'https://dev1.andwellness.org/app'},
	                    	{server: 'https://dev.mobilizingcs.org/app'},
	                    	{server: 'https://dev1.mobilizingcs.org/app'},
	                    	{server: 'https://dev3.mobilizingcs.org/app'}
	                    ]
	                },
	                value: 'https://dev3.mobilizingcs.org/app',
	                displayField: 'server',
	                valueField: 'server'
	            }
	        ]
	    },
	    buttons: [
	        {
	            text: 'Login',
	            iconCls: 'login16',
	            handler: function(){
	            	USERNAME = "'" + Ext.getCmp('username_field').getValue() + "'";
	            	PASSWORD = "'" + Ext.getCmp('password_field').getValue() + "'";
	            	SERVER = "'" + Ext.getCmp('server_field').getValue() + "'";
	            	authenticate()
	            }
	        }
	    ]
	});
	Ext.win2.show();
 
});

