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
    
    property int itemWidth: 90;

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
                    left: parent.left;
                    verticalCenter: parent.verticalCenter;
                }

                height: parent.height * 0.5;
                width: height;
                elementId: ConnectionIcon;
                svg: PlasmaCore.Svg { multipleImages: true; imagePath: "icons/network" }
            }
            
            Text {
                text: i18n("⬇ %1/s\n⬆ %2/s",
                            KCoreAddons.Format.formatByteSize(dataSource.data[dataSource.downloadSource].value * 1024 || 0),
                            KCoreAddons.Format.formatByteSize(dataSource.data[dataSource.uploadSource].value * 1024 || 0))
                color: theme.textColor
                width: parent.width - connectionSvgIcon.width
                anchors {
                    left: connectionSvgIcon.right;
                    verticalCenter: parent.verticalCenter
                }
            }
            
        }
    }
    
}
