var lowerMaxBytesTimeoutMs = 5 * 1000

var deviceInfoMap = {}

var SpeedType = {
    Download: 1,
    Upload: 2
}


function addSpeedData(speed, model, graphGranularity, itemHeight, scaleCoeficient) {
    
    // initial fill up
    while (model.count < graphGranularity) {
        model.append({
            'speed': 0,
            'graphItemHeight': 0
        })
    }
    
    // do not allow scaling up (no point) - scaling down is for bigger maxBytes data
    if (scaleCoeficient === 1) {
        // ok
    } else if (scaleCoeficient > 1) {
        scaleCoeficient = 1
    } else if (scaleCoeficient < 1 && scaleCoeficient > 0) {
        scaleCoeficient = Math.log(scaleCoeficient * 100) / Math.log(100)
    }
    
    var nextHistory = model.maxBytes <= 0 ? 0 : speed / model.maxBytes
    nextHistory = nextHistory * itemHeight
    
    var newItem = {
        'speed': speed,
        'graphItemHeight': nextHistory * scaleCoeficient
    }
    
    model.append(newItem)
    model.remove(0)
    
    var oldMaxBytes = model.maxBytes
    
    // this speed is max
    if (speed >= model.maxBytes) {
        
        model.maxBytes = speed
        model.maxBytesModelIndex = model.count - 1
        
        recalculate(model, oldMaxBytes)
        return
    }
    
    
    //
    // incomming speed is not max
    //
    
    // decrement maxBytes model index (new speed was pushed)
    model.maxBytesModelIndex--
    var nowMs = new Date().getTime()
    
    // maxSpeed is out of array? -> start lowering countdown...
    if (model.maxBytesModelIndex < 0 && model.lowerMaxBytesInMs === -1) {
        
        model.lowerMaxBytesInMs = nowMs + lowerMaxBytesTimeoutMs
        
    } else if (model.lowerMaxBytesInMs !== -1 && nowMs > model.lowerMaxBytesInMs) {
        
        // lowering countdown is timed out -> lower maxBytes to next existing maxBytes
        model.lowerMaxBytesInMs = -1
        model.maxBytesModelIndex = 0
        model.maxBytes = 0
        
        for (var i = 0; i < model.count; i++) {
            var itemSpeed = model.get(i).speed
            if (itemSpeed > model.maxBytes) {
                model.maxBytes = itemSpeed
                model.maxBytesModelIndex = i
            }
        }
        
        recalculate(model, oldMaxBytes)
        
    }
    
}

function recalculate(model, oldMaxBytes) {
    
    if (model.maxBytes === oldMaxBytes || model.maxBytes === 0) {
        return
    }
    
    var recalculateNumber = oldMaxBytes / model.maxBytes
    for (var i = 0; i < model.count; i++) {
        var itemHeight = model.get(i).graphItemHeight
        model.setProperty(i, 'graphItemHeight', itemHeight * recalculateNumber)
    }
}

