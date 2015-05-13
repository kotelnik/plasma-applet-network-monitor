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
    
    property int itemWidth: main.vertical ? parent.width : parent.height
    property int itemHeight: main.vertical ? parent.width : parent.height
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
    
    Layout.minimumWidth: Layout.maximumWidth
    Layout.minimumHeight: Layout.maximumHeight
    
    Layout.maximumWidth:   main.vertical ? parent.width  : (main.itemWidth  + itemMargin) * filteredByNameModel.count - itemMargin + (showLo ? main.itemWidth  + itemMargin : 0)
    Layout.maximumHeight: !main.vertical ? parent.height : (main.itemHeight + itemMargin) * filteredByNameModel.count - itemMargin + (showLo ? main.itemHeight + itemMargin : 0)
    
    
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
    }
    
    ListView {
        id: loContainer
        anchors.top: parent.top
        anchors.left: parent.left
        
        width: main.itemWidth
        height: main.itemHeight
        
        visible: showLo
        
        interactive: false
        
        model: ListModel {
            ListElement {
                DeviceName: 'lo'
            }
        }
        
        delegate: ActiveConnection {}
    }
    
    ListView {
        anchors.top: parent.top
        anchors.left: parent.left
        
        width: main.itemWidth
        height: main.itemHeight
        
        visible: !showLo && filteredByNameModel.count === 0
        
        interactive: false
        
        model: ListModel {
            ListElement {
                DeviceName: '_'
            }
        }
        
        delegate: ActiveConnection {
            noConnection: true
        }
    }
    
    ListView {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: showLo && !vertical ? itemMargin + loContainer.width : 0
        anchors.topMargin: showLo && vertical ? itemMargin + loContainer.height : 0
        
        interactive: false
        orientation: main.vertical ? ListView.Vertical : ListView.Horizontal
        
        spacing: itemMargin
        
        width: main.vertical ? itemWidth : itemWidth * filteredByNameModel.count
        height: main.vertical ? itemHeight * filteredByNameModel.count : itemHeight
        
        model: filteredByNameModel
        
        delegate: ActiveConnection {}
    }
    
    
}
