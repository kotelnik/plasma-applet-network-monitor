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
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

Item {
    id: main
    
    // general settings
    property bool showLo: plasmoid.configuration.showLo
    property double updateInterval: plasmoid.configuration.updateInterval * 1000
    
    // filter settings
    property int deviceFilterType: plasmoid.configuration.deviceFilterType
    property string deviceWhiteListRegexp: '^(' + plasmoid.configuration.deviceWhiteListRegexp + ')$'
    property string deviceBlackListRegexp: '^(?!(' + plasmoid.configuration.deviceBlackListRegexp + '))'
    
    // appearance settings
    property double iconOpacity: plasmoid.configuration.iconOpacity
    property double iconBlur: plasmoid.configuration.iconBlur
    property bool showDeviceNames: plasmoid.configuration.showDeviceNames
    property bool historyGraphsEnabled: plasmoid.configuration.historyGraphsEnabled
    
    //
    // sizing and spacing
    //
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    
    property bool showBiggerNumbers: plasmoid.configuration.showBiggerNumbers
    
    property double baseSizeMultiplier: plasmoid.configuration.baseSizeMultiplier
    property int itemMargin: 5
    
    property double itemAspectRatio: !showDeviceNames && showBiggerNumbers ? 4 / 3 : 1
    
    property double parentWidth: parent === null ? 0 : parent.width
    property double parentHeight: parent === null ? 0 : parent.height
    
    property double maxAllowedWidth: vertical ? parentWidth : parentHeight * itemAspectRatio
    property double maxAllowedHeight: maxAllowedWidth / itemAspectRatio
    
    property double preMaxBaseWidth: theme.mSize(theme.defaultFont).width * 3 * baseSizeMultiplier
    property int maxBaseWidth: 10
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
        maxBaseWidth = vertical ? Math.min(preMaxBaseWidth, maxAllowedWidth) : Math.min(preMaxBaseWidth, maxAllowedHeight / itemAspectRatio)
        gridColumns = vertical ? Math.min(Math.ceil(maxAllowedWidth / maxBaseWidth), networkDevicesModel.count) : 100
        gridRows = vertical ? 100 : Math.min(Math.floor(maxAllowedHeight / (maxBaseWidth / itemAspectRatio)), networkDevicesModel.count)
        
        if (!vertical) {
            gridColumns = Math.ceil(networkDevicesModel.count / gridRows)
        }
    
        itemWidth = vertical ? (parentWidth / gridColumns) - (itemMargin * 0.5 * (gridColumns - 1)) : ((parentHeight / gridRows) * itemAspectRatio) - (itemMargin * 0.5 * (gridRows - 1))
        itemHeight = itemWidth / itemAspectRatio
        
        widgetWidth = vertical ? parentWidth : (itemWidth + itemMargin) * Math.ceil(networkDevicesModel.count / gridRows) - itemMargin
        widgetHeight = vertical ? (itemHeight + itemMargin) * Math.ceil(networkDevicesModel.count / gridColumns) - itemMargin : parentHeight
        
        main.width = widgetWidth
        main.height = widgetHeight
    }
    
    anchors.fill: parent
    
    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    PlasmaCore.SortFilterModel {
        id: activeNetworksModel
        filterRole: 'ConnectionState'
        filterRegExp: '2'
        sourceModel: connectionModel
    }

    PlasmaCore.SortFilterModel {
        id: filteredByNameModel
        filterRole: 'DeviceName'
        filterRegExp: deviceFilterType === 0 ? '' : deviceFilterType === 1 ? deviceWhiteListRegexp  : deviceBlackListRegexp
        sourceModel: activeNetworksModel
        onCountChanged: devicesChanged()
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
        } else if (filteredByNameModel.count === 0) {
            networkDevicesModel.append({
                DeviceName: '_',
                ConnectionIcon: ''
            })
        }
        for (var i = 0; i < filteredByNameModel.count; i++) {
            var origObj = filteredByNameModel.get(i)
            networkDevicesModel.append({
                DeviceName: origObj.DeviceName,
                ConnectionIcon: origObj.ConnectionIcon
            })
        }
        setItemSize()
    }
    
    onShowLoChanged: devicesChanged()
    
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
