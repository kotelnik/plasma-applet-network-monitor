var lowerMaxBytesTimeoutMs = 5 * 1000

var deviceInfoMap = {}

var SpeedType = {
    Download: 1,
    Upload: 2
}


function addSpeedData(speed, model, graphGranularity, scaleCoeficient) {
    
    // initial fill up
    while (model.count > graphGranularity) {
        model.remove(0, model.count - graphGranularity)
    }
    while (model.count < graphGranularity) {
        model.insert(0, {
            'speed': 0,
            'graphItemPercent': 0
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
    
    var newItem = {
        'speed': speed,
        'graphItemPercent': nextHistory * scaleCoeficient
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
        var itemPercent = model.get(i).graphItemPercent
        model.setProperty(i, 'graphItemPercent', itemPercent * recalculateNumber)
    }
}


function transformNumber(sourceNumber, peak, maxLength, suffixes) {
    
    var lengthLimitNumber = Math.pow(10, maxLength)
    
    var number = sourceNumber
    
    var suffixIndex = 0
    
    while (number >= lengthLimitNumber || number >= peak) {
        number /= peak
        suffixIndex++
    }
    
    // now we have result number -> we need to round it right:
    var numberForRounding = number
    var roundingDivider = 1
    var limitForRounding = lengthLimitNumber / 10
    while (numberForRounding < limitForRounding && numberForRounding > 0) {
        numberForRounding *= 10
        roundingDivider *= 10
    }
    
    var resultNumberStr = (Math.round(numberForRounding) / roundingDivider).toString()
    
    return resultNumberStr + suffixes[suffixIndex]
    
}
