function handleMessage(gameId, bookId, width, broadcasterName, userId, widthUnit, appURL, deviceType) {
    try {
        if(!widthUnit) {
            widthUnit = 'px';
        }
        widthUnit = '%';
        width = '100';
        if(gameId && bookId){
            //            Dynamically create a placeholder div for panel
            createDivForReactNative(gameId, bookId, width, broadcasterName, userId, widthUnit);
            //            Load all the react native scripts
            loadReactLiveScriptAPI(appURL);
            //            Helper functions
            //            helperTapppFn(gameId, bookId, width);
        }
    } catch(e) {
        console.log('...Error on handle message', e);
    }
}

function myFunction1(gameId, bookId, width, broadcasterName, userId, widthUnit, appURL, deviceType) {
    createDivForReactNative(gameId, bookId, width, broadcasterName, userId, widthUnit);
    loadReactLiveScriptAPI(appURL);
    return userId;
}

function myFunction(gameId, bookId, width, broadcasterName, userId, widthUnit, appURL, deviceType) {
    gameId = 'cb0403c8-0f3c-4778-8d26-c4a63329678b';
    bookId = '1000009';
    width = '300';
    broadcasterName = 'TRN';
    userId = 'cf9bb061-a040-4f43-56546-525252678b';
    widthUnit = 'px';
    deviceType = 'iPhone';
    appURL = 'https://apps.tappp.com/mlr/mobile/bundle.js';

    createDivForReactNative(gameId, bookId, width, broadcasterName, userId, widthUnit);
    loadReactLiveScriptAPI(appURL);
    return gameId;
}

function createDivForReactNative(gameId, bookId, width, broadcasterName, userId, widthUnit) {
    const rootDiv = document.createElement('div');
    const rootTag = "<div id='tappp-panel' userid='"+ userId +"' bookid='"+ bookId +"' gameid='"+ gameId +"' width='"+ width +"' widthunit='" + widthUnit +"' broadcastername='" + broadcasterName + "' ></div>";
    rootDiv.innerHTML = rootTag;
    
    document.body.appendChild(rootDiv);
    
}

function loadReactLiveScriptAPI(url) {
    const scriptTag = document.createElement('script');
    scriptTag.type = 'text/javascript';
    scriptTag.src = url
    document.body.appendChild(scriptTag);
}

//    Do specific thing once the script loaded
function callFunctionFromScript(gameId, bookId, width, calledFrom) {
    const scritpTagFn = 'scriptOnloadTag';
    const divErr = document.createElement('div');
    divErr.innerHTML = calledFrom;
    document.getElementById(scritpTagFn).appendChild(divErr);
}

function helperTapppFn(gameId, bookId, width) {
    const helperDiv = document.createElement('div');
    let gameTag = "<input type='text' name='value' id='gameId' value='"+gameId+"' />";
    let bookTag = "<input type='text' name='value' id='bookId' value='"+bookId+"' />";
    let widthTag = "<input type='text' name='value' id='widthId' value='"+width+"' />";
    
    helperDiv.innerHTML = gameTag + bookTag + widthTag +`
            <label>
              <input type="checkbox" name="check" value="1" /> Checked?
            </label>
            <input type="button" value="-" onclick="removeRow(this)" />
          `;
    document.getElementById('parentId').appendChild(helperDiv);
}

function callNative() {
    webkit.messageHandlers.callNative.postMessage({
        "message": "callNative method data passes"
    });
}

function nativeToJs(objPanelData){
    console.log("....objPanelData in js=", objPanelData)
}

function showiOSToast() {
    let nameField = document.getElementById('nameField').value;
    webkit.messageHandlers.toggleMessageHandler.postMessage({
        "message": nameField
    });
}
