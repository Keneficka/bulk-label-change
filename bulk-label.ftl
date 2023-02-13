<#-- get the roles of the current user and check for "Administrator"-->
<#assign userRoles = (restBuilder().admin(true).liql("SELECT name FROM roles WHERE users.id = '${user.id?c}'").data.items)![]/>
<#assign admin = "false">
<#list userRoles as role>
    <#if role.name == "Administrator">
        <#assign admin = "true" />
    </#if>
</#list>

<#if admin == "true">
	<p>Reminders! Turn off "Require labels on posts" if you are only deleting. Add new labels to the list of predefined labels <b>first</b> if predefined labels are required.<br>
	Do not remove old labels from the list of predefined labels until replacement is complete. Alternatively, switch to "Use both user-defined and predefined labels".</p>

	<table>
		<tr>
			<td style="background-color: lightgrey;">Board ID : </td><td><input type="text" id="boardIdTextBox"><td>
		</tr>
		<tr>
			<td style="background-color: lightgrey;">Keyword To Search <span style="font-size: small;">(Alphanumeric Only Can Be Left Blank)</span>: </td><td><input type="text" id="keywordTextBox"></td>
		</tr>
		<tr>
			<td style="background-color: lightgrey;">Old Label To Be Deleted : </td><td><input type="text" id="oldLabelTextBox"></td>
		</tr>
		<tr>
			<td style="background-color: lightgrey;">New Label To Add <span style="font-size: small;">(Can Be Left Blank)</span>: </td><td><input type="text" id="newLabelTextBox"></td>
		</tr>
	</table>
	<br><br>
	<button id="AKchangeLabelButton" style="font-size: x-large;">Go</button>


	<script>
	var boardID;
	var oldLabel;
	var encodedOldLabel;
	var newLabel;
	var keyword;

	document.getElementById("AKchangeLabelButton").onclick = function() {replace()};



	function replace(){
		keyword = document.getElementById("keywordTextBox").value;
		if(keyword){
			keyword = '"' + keyword + '"';
		}
		boardID = document.getElementById("boardIdTextBox").value;
		oldLabel = document.getElementById("oldLabelTextBox").value;
		encodedOldLabel = encodeURIComponent(oldLabel);
		newLabel = document.getElementById("newLabelTextBox").value;

		
		var getMessageListReq = new XMLHttpRequest();
		var getMessageCall = "/api/2.0/search?q=" + encodeURIComponent("SELECT id FROM messages WHERE labels.text = '" + oldLabel + "' and board.id = '" + boardID + "' and (body MATCHES '" + keyword + "' OR subject MATCHES '" + keyword + "') LIMIT 1000");

			console.log(getMessageCall);

		getMessageListReq.open("GET", getMessageCall);
		
		getMessageListReq.onload = function(){
			var messageList = JSON.parse(getMessageListReq.response);
					console.log(messageList.status);
			var size = messageList.data.size;
			
			if (size > 0){
				
				for (var i = 0; i < size; i++){				
					if (newLabel){
						add(messageList.data.items[i].id);
					}
					del(messageList.data.items[i].id);
				}		

				replace();
			}
			else{
				console.log("Done");
			}
			
		}
		
		getMessageListReq.send();
	}

	function add(id){
	var addLabelReq = new XMLHttpRequest();
	var call = "/api/2.0/messages/" + id + "/labels";
	var body = '{"data":{"type":"label","text":"' + newLabel + '"}}';
	addLabelReq.open("POST", call, false);

	addLabelReq.setRequestHeader('Content-type', 'application/json');


	addLabelReq.onload = function(){
		resp = addLabelReq.response;
		console.log(resp);
	}

	addLabelReq.send(body);
	}

	function del(id){
	var delLabelReq = new XMLHttpRequest();
	var call = "/api/2.0/messages/" + id + "/labels/" + encodedOldLabel;

	delLabelReq.open("DELETE", call, false);

	delLabelReq.onload = function(){
		resp = delLabelReq.response;
		console.log(resp);
	}
	delLabelReq.send();
	}


	</script>
<#else>
	You are not authorized to access this page. Make sure you are logged in.
</#if>