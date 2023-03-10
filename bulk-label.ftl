<#-- get the roles of the current user and check for "Administrator"-->
<#assign userRoles = (restBuilder().admin(true).liql("SELECT name FROM roles WHERE users.id = '${user.id?c}'").data.items)![]/>
<#assign admin = "false">
<#list userRoles as role>
    <#if role.name == "Administrator">
        <#assign admin = "true" />
    </#if>
</#list>

<#if admin == "true">
    <p>Reminders! Add new labels to the list of predefined labels <b>first</b> if predefined labels are required. Do not remove old labels from the list of predefined labels until replacement is complete. Alternatively, switch <br>
    to "Use both user-defined and predefined labels". <b>UPDATE</b> If you are only deleting labels they will only be removed from posts with multiple labels, so you no longer need to turn off "Require labels on posts".</p>

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
    var cursor;
    var isMore;
    var deleteOnly = true;

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
        cursor = '';
        isMore = false;
        
        getMessages();

        while (isMore) {
            getMessages();
        }

        console.log('Done')
    }


    /***getMessages function***/
    function getMessages() {
        var getMessageListReq = new XMLHttpRequest();
        var getMessageCall
        if (cursor) {
            getMessageCall = "/api/2.0/search?q=" + encodeURIComponent("SELECT id, labels.count(*) FROM messages WHERE depth=0 AND labels.text = '" + oldLabel + "' and board.id = '" + boardID + "' and (body MATCHES '" + keyword + "' OR subject MATCHES '" + keyword + "') LIMIT 1000 CURSOR '" + cursor + "'");
        } else {
            getMessageCall = "/api/2.0/search?q=" + encodeURIComponent("SELECT id, labels.count(*) FROM messages WHERE depth=0 AND labels.text = '" + oldLabel + "' and board.id = '" + boardID + "' and (body MATCHES '" + keyword + "' OR subject MATCHES '" + keyword + "') LIMIT 1000");
        }
        console.log(getMessageCall);

        getMessageListReq.open("GET", getMessageCall, false);
        
        getMessageListReq.onload = function(){
            var messageList = JSON.parse(getMessageListReq.response);
            console.log(messageList.status);
            if (messageList.data.next_cursor) {
                cursor = messageList.data.next_cursor;
                isMore = true;
            } else {
                isMore = false;
            }

            var size = messageList.data.size;
            
            if (newLabel) {
                for (var i = 0; i < size; i++){				
                    add(messageList.data.items[i].id);
                    del(messageList.data.items[i].id);
                }
            } else {
                for (var i = 0; i < size; i++){				
                    if (messageList.data.items[i].labels.count > 1) {
                        del(messageList.data.items[i].id);
                    }
                }
            }
        }
        getMessageListReq.send();
    }/***end getMessages***/


    /***add function***/
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
    }/***end add***/


    /***del function***/
    function del(id){
        var delLabelReq = new XMLHttpRequest();
        var call = "/api/2.0/messages/" + id + "/labels/" + encodedOldLabel;

        delLabelReq.open("DELETE", call, false);

        delLabelReq.onload = function(){
            resp = delLabelReq.response;
            console.log(resp);
        }
        delLabelReq.send();
    }/***end del***/


    </script>
<#else>
    You are not authorized to access this page. Make sure you are logged in.
</#if>