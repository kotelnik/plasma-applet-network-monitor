/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/devices-model-helper.js" as DevicesModelHelper

Item {
    id: main
    
    // general settings
    property bool showLo: plasmoid.configuration.showLo
    property bool showDdWrt: plasmoid.configuration.showDdWrt
    property double updateInterval: plasmoid.configuration.updateInterval * 1000
    
    // filter settings
    property int deviceFilterType: plasmoid.configuration.deviceFilterType
    property string deviceWhiteListRegexp: '^(' + plasmoid.configuration.deviceWhiteListRegexp + ')$'
    property string deviceBlackListRegexp: '^(?!(' + plasmoid.configuration.deviceBlackListRegexp + '))'
    property string filterRegExp: deviceFilterType === 0 ? '' : deviceFilterType === 1 ? deviceWhiteListRegexp  : deviceBlackListRegexp
    
    property string ddwrtHost: plasmoid.configuration.ddwrtHost
    property string ddwrtKey: Qt.atob(plasmoid.configuration.ddWrtUser + ":" + plasmoid.configuration.ddWrtPassword)

    // appearance settings
    property double iconOpacity: plasmoid.configuration.iconOpacity
    property double iconBlur: plasmoid.configuration.iconBlur
    property bool historyGraphsEnabled: plasmoid.configuration.historyGraphsEnabled
    // 0 - full view, 1 - no device names, 2 - big numbers, 3 - one line
    property int layoutType: plasmoid.configuration.layoutType
    property bool showBits: plasmoid.configuration.showBits

    //
    // sizing and spacing
    //
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    
    property double baseSizeMultiplier: plasmoid.configuration.baseSizeMultiplier
    property int itemMargin: 5
    
    // 0 - both, 1 - only download, 2 - only upload
    property int showUploadDownload: plasmoid.configuration.showUploadDownload
    property bool hideDownload: showUploadDownload === 2
    property bool hideUpload: showUploadDownload === 1
    property double itemAspectRatio: layoutType === 2 ? 4/3 : layoutType === 3 ? (showUploadDownload === 0 ? 6.25 : 3) : 1
    
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    
    property double maxAllowedWidth: vertical ? parentWidth : parentHeight * itemAspectRatio
    property double maxAllowedHeight: maxAllowedWidth / itemAspectRatio
    
    property double preMaxBaseWidth: theme.mSize(theme.defaultFont).width * 5 * baseSizeMultiplier
    property double maxBaseWidth: 10
    property int gridColumns: 1
    property int gridRows: 1
    
    property double itemWidth: 10
    property double itemHeight: 10
    
    property double widgetWidth: 10
    property double widgetHeight: 10
    
    Layout.preferredWidth: widgetWidth
    Layout.preferredHeight: widgetHeight
    Layout.maximumWidth: widgetWidth
    Layout.maximumHeight: widgetHeight
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
    property bool debugLogging: false
    
    function dbgprint(msg) {
        if (!debugLogging) {
            return
        }
        print('[networkMonitor] ' + msg)
    }
    
    onMaxAllowedHeightChanged: {
        setItemSize()
    }
    
    onMaxAllowedWidthChanged: {
        setItemSize()
    }
    
    onPreMaxBaseWidthChanged: {
        setItemSize()
    }
    
    function setItemSize() {
        maxBaseWidth = vertical ? Math.min(preMaxBaseWidth, maxAllowedWidth) : Math.min(preMaxBaseWidth, maxAllowedHeight * itemAspectRatio)
        gridColumns = vertical ? Math.min(Math.ceil(maxAllowedWidth / maxBaseWidth), networkDevicesModel.count) : 100
        gridRows = vertical ? 100 : Math.min(Math.ceil(maxAllowedHeight / (maxBaseWidth / itemAspectRatio)), networkDevicesModel.count)
        
        if (!vertical) {
            gridColumns = Math.ceil(networkDevicesModel.count / gridRows)
        }
    
        itemWidth = vertical ? (parentWidth / gridColumns) - (itemMargin * 0.5 * (gridColumns - 1)) : ((parentHeight / gridRows) * itemAspectRatio) - (itemMargin * 0.5 * (gridRows - 1))
        itemHeight = itemWidth / itemAspectRatio + (layoutType === 3 ? - itemMargin : 0)
        
        widgetWidth = vertical ? parentWidth : (itemWidth + itemMargin) * Math.ceil(networkDevicesModel.count / gridRows) - itemMargin
        widgetHeight = vertical ? (itemHeight + itemMargin) * Math.ceil(networkDevicesModel.count / gridColumns) - itemMargin : parentHeight
        
        main.width = widgetWidth
        main.height = widgetHeight
    }

    anchors.fill: parent
    
    PlasmaCore.DataSource {
        id: systemmonitorDS
        engine: 'systemmonitor'
        onSourceAdded: {
            sourceAddedOrRemoved(source, true)
        }
        onSourceRemoved: {
            sourceAddedOrRemoved(source, false)
        }
    }
    
    PlasmaCore.DataSource {
        id: executableDS
        engine: 'executable'
        
        connectedSources: []
        
        onNewData: {
            if (data['exit code'] > 0) {
                return
            }
            DevicesModelHelper.setConnectionState(connectionModel, sourceName, data.stdout)
        }
        
        interval: 1000
    }
    
    function sourceAddedOrRemoved(source, added) {
        DevicesModelHelper.tryAddOrRemoveConnection(connectionModel, source, executableDS, added)
    }
    
    Component.onCompleted: {
        reloadComponent()
    }
    
    function reloadComponent() {
        dbgprint('completed')
        dbgprint('systemmonitorDS:')
        systemmonitorDS.sources.forEach(function (source) {
            dbgprint('  ' + source)
            sourceAddedOrRemoved(source, true)
        })
        dbgprint('connectionModel:')
        for (var i = 0; i < connectionModel.count; i++) {
            var obj = connectionModel.get(i)
            dbgprint('  ' + obj.DeviceName + ', ' + obj.ConnectionIcon + ', ' + obj.ConnectionState + ', ' + i)
        }
        devicesChanged()
    }
    
    onFilterRegExpChanged: {
        devicesChanged()
    }
    
    ListModel {
        id: connectionModel
    }

    DdWrtClient {
        id: ddWrt
    }
    
    ListModel {
        id: networkDevicesModel
    }

    function devicesChanged() {
        networkDevicesModel.clear()

        if (showLo) {
            networkDevicesModel.append({
                DeviceName: 'lo',
                ConnectionIcon: ''
            })
        }
        
        if (showDdWrt) {
            networkDevicesModel.append({
                DeviceName: 'DD-WRT',
                ConnectionIcon: ''
            })
        }
        
        // filter connectionModel
        var filterRegExp = deviceFilterType === 0 ? '' : deviceFilterType === 1 ? deviceWhiteListRegexp  : deviceBlackListRegexp
        var filteredModel = []
        for (var i = 0; i < connectionModel.count; i++) {
            var obj = connectionModel.get(i)
            if (obj.ConnectionState === 2 && obj.DeviceName.match(filterRegExp)) {
                filteredModel.push(obj)
            }
        }
        
        if (filteredModel.length === 0 && !showLo && !showDdWrt) {
            networkDevicesModel.append({
                DeviceName: '_',
                ConnectionIcon: ''
            })
        }
        
        filteredModel.forEach(function (origObj) {
            networkDevicesModel.append({
                DeviceName: origObj.DeviceName,
                ConnectionIcon: origObj.ConnectionIcon
            })
        })
        setItemSize()
    }
    
    onShowLoChanged: devicesChanged()
    onShowDdWrtChanged: devicesChanged()

    GridLayout {
        columns: gridColumns
        columnSpacing: itemMargin
        rowSpacing: itemMargin
        
        width: main.width
        height: main.height
        
        Layout.preferredWidth: width
        Layout.preferredHeight: height
        
        Repeater {
            model: networkDevicesModel
            delegate: ActiveConnection {
                Layout.preferredWidth: itemWidth
                Layout.preferredHeight: itemHeight
            }
        }
    }
    
}
