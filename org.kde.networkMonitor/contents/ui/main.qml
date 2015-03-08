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
    
    property int itemWidth: theme.smallestFont.pixelSize * 6;

    Layout.maximumWidth: main.preferredSize.width
    Layout.maximumHeight: Infinity
    
    Layout.minimumWidth: Layout.maximumWidth
    Layout.minimumHeight: Layout.maximumHeight

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Layout.fillHeight: true
    
    anchors.fill: parent

    PlasmaNM.NetworkModel {
        id: connectionModel
    }

    PlasmaCore.SortFilterModel {
        id: activeNetworksModel
        filterRole: "ConnectionState"
        filterRegExp: "2"
        sourceModel: connectionModel
        onCountChanged: {
            main.Layout.preferredWidth = count * itemWidth
        }
    }
    
    
    ListView {
        id: networkList
        anchors.fill: parent
        orientation: ListView.Horizontal
        
        model: activeNetworksModel
        
        delegate: Item {
            height: main.height
            width: itemWidth
            
            PlasmaCore.DataSource {
                id: dataSource;

                property string downloadSource: "network/interfaces/" + DeviceName + "/receiver/data";
                property string uploadSource: "network/interfaces/" + DeviceName + "/transmitter/data";

                engine: "systemmonitor";
                connectedSources: [downloadSource, uploadSource];
                interval: 1000;
            }
            
            PlasmaCore.SvgItem {
                id: connectionSvgIcon;

                anchors {
                    right: parent.right
                    top: parent.top
                }
                
                opacity: 0.3

                height: parent.height;
                width: height;
                elementId: ConnectionIcon;
                svg: PlasmaCore.Svg { multipleImages: true; imagePath: "icons/network" }
            }
            
            Text {
                text: DeviceName
                
                anchors.top: parent.top
                anchors.left: parent.left
                
                color: theme.textColor
                
                font.italic: true
                font.pointSize: theme.smallestFont.pointSize
            }
            
            Text {
                id: connectionSpeed
                
                text: i18n("⬇%1\n⬆%2",
                            KCoreAddons.Format.formatByteSize(dataSource.data[dataSource.downloadSource].value * 1024 || 0),
                            KCoreAddons.Format.formatByteSize(dataSource.data[dataSource.uploadSource].value * 1024 || 0))
                color: theme.textColor
                font.pointSize: theme.smallestFont.pointSize
                
                anchors {
                    left: parent.left;
                    bottom: parent.bottom
                }
            }
            
        }
    }
    
}
