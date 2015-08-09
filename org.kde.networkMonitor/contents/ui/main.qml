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
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
    id: main
    
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    
    property bool showBiggerNumbers: plasmoid.configuration.showBiggerNumbers
    property int rows: 1
    property double aspectRatio: !showDeviceNames && showBiggerNumbers ? 4 / 3 : 1
    
    property int itemHeight: main.vertical ? parent.width / aspectRatio : parent.height
    property int itemWidth: itemHeight * aspectRatio
    property int itemMargin: 5
    
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
    
    
    Layout.preferredWidth:   main.vertical ? parent.width  : (main.itemWidth  + itemMargin) * networkDevicesModel.count - itemMargin
    Layout.preferredHeight: !main.vertical ? parent.height : (main.itemHeight + itemMargin) * networkDevicesModel.count - itemMargin
    
    
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    
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
                DeviceName: 'lo'
            })
        } else if (filteredByNameModel.count === 0) {
            networkDevicesModel.append({
                DeviceName: '_'
            })
        }
        for (var i = 0; i < filteredByNameModel.count; i++) {
            networkDevicesModel.append(filteredByNameModel.get(i))
        }
    }
    
    onShowLoChanged: devicesChanged()
    
    ListView {
        
        interactive: false
        orientation: main.vertical ? ListView.Vertical : ListView.Horizontal
        
        spacing: itemMargin
        
        width: main.vertical ? itemWidth : itemWidth * networkDevicesModel.count
        height: main.vertical ? itemHeight * networkDevicesModel.count : itemHeight
        
        model: networkDevicesModel
        
        delegate: ActiveConnection {}
    }
    
}
