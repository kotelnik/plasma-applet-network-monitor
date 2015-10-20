var modelIndexByCmdSource = {}

var stateCmdPattern = 'ip addr show dev {deviceName}';

var networkSourceStartLength = 'network/interfaces/'.length
var networkSourceEndLength = '/transmitter/data'.length

function tryAddOrRemoveConnection(devicesModel, source, executableDS, added) {
    if (!source.match(/^network\/interfaces\/(\w+)\/transmitter\/data$/)) {
        return
    }
    
    var deviceName = source.substring(networkSourceStartLength, source.length - networkSourceEndLength)
    if (deviceName === 'lo') {
        return
    }
    
    if (added) {
        dbgprint('ADDED: ' + deviceName)
        DevicesModelHelper.addConnection(devicesModel, deviceName, executableDS)
    } else {
        dbgprint('REMOVED: ' + deviceName)
        DevicesModelHelper.removeConnection(devicesModel, deviceName, executableDS)
    }
}

function addConnection(devicesModel, deviceName, executableDS) {
    
    var stateCmd = stateCmdPattern.replace('{deviceName}', deviceName)
    var devicesModelIndex = modelIndexByCmdSource[stateCmd]
    
    if (devicesModelIndex >= 0) {
        devicesModel.remove(devicesModelIndex)
    }
    modelIndexByCmdSource[stateCmd] = devicesModel.count
    
    var connectionIcon = deviceName.indexOf('e') === 0 ? 'network-wired-activated' : deviceName.indexOf('w') === 0 ? 'network-wireless-connected-100' : 'network-wired'
    dbgprint('connecting with connection icon: ' + connectionIcon)
    
    devicesModel.append({
        ConnectionState: 0,
        DeviceName: deviceName,
        ConnectionIcon: connectionIcon
    })
    
    sortDevicesModelAndRebuildIndex(devicesModel)
    
    dbgprint('connecting executable source: ' + stateCmd)
    executableDS.connectSource(stateCmd)
    
    main.devicesChanged()
    
}

function removeConnection(devicesModel, deviceName, executableDS) {
    
    var stateCmd = stateCmdPattern.replace('{deviceName}', deviceName)
    dbgprint('disconnecting executable source: ' + stateCmd)
    executableDS.disconnectSource(stateCmd)
    
    var devicesModelIndex = modelIndexByCmdSource[stateCmd]
    dbgprint('removing from devices model, index: ' + devicesModelIndex)
    delete modelIndexByCmdSource[stateCmd]
    devicesModel.remove(devicesModelIndex)
    rebuildIndex(devicesModel)
    
    main.devicesChanged()
    
}

function setConnectionState(devicesModel, cmdSource, state) {
    
    var devicesModelIndex = modelIndexByCmdSource[cmdSource]
    dbgprint('setting connection state - cmd: ' + cmdSource + ', index=' + devicesModelIndex + ', stateString.length: ' + state.length)
    
    if (devicesModelIndex >= 0) {
        var oldValue = devicesModel.get(devicesModelIndex).ConnectionState
        var newValue = determineConnectedFromString(state)
        
        devicesModel.setProperty(devicesModelIndex, 'ConnectionState', newValue)
        
        if (oldValue !== newValue) {
            main.devicesChanged()
        }
    }
}

function determineConnectedFromString(stateString) {
    var connectionState = stateString.trim()
    return connectionState.indexOf('inet') !== -1 ? 2 : 0
}

function rebuildIndex(devicesModel) {
    modelIndexByCmdSource = {}
    for (var i = 0; i < devicesModel.count; i++) {
        var obj = devicesModel.get(i)
        var stateCmd = stateCmdPattern.replace('{deviceName}', obj.DeviceName)
        modelIndexByCmdSource[stateCmd] = i
    }
}

function sortDevicesModelAndRebuildIndex(devicesModel) {
    var eArray = []
    var wArray = []
    var otherArray = []
    
    for (var i = 0; i < devicesModel.count; i++) {
        var origObj = devicesModel.get(i)
        var obj = {
            DeviceName: origObj.DeviceName,
            ConnectionIcon: origObj.ConnectionIcon,
            ConnectionState: origObj.ConnectionState
        }
        var firstLetter = obj.DeviceName.substring(0, 1)
        if (firstLetter === 'e') {
            eArray.push(obj)
        } else if (firstLetter === 'w') {
            wArray.push(obj)
        } else {
            otherArray.push(obj)
        }
    }
    
    devicesModel.clear()
    eArray.forEach(function (obj) {
        devicesModel.append(obj)
    })
    wArray.forEach(function (obj) {
        devicesModel.append(obj)
    })
    otherArray.forEach(function (obj) {
        devicesModel.append(obj)
    })
    
    rebuildIndex(devicesModel)
}
