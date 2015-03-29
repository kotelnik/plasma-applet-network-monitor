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
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
    id: activeConnection
    
    width: main.itemWidth
    height: main.itemHeight
    
    property double fontPointSize: height * 0.195 * (main.showDeviceNames ? 1 : 1.25)
    
    function formatBytes(bytes) {
        var localBytes = bytes;
        var suffix = 'B';
        if (localBytes >= 1024) {
            localBytes = localBytes / 1024;
            suffix = 'K';
        } else {
            return formatSize(localBytes, suffix);
        }
        if (localBytes >= 1024) {
            localBytes = localBytes / 1024;
            suffix = 'M';
        } else {
            return formatSize(localBytes, suffix);
        }
        if (localBytes >= 1024) {
            localBytes = localBytes / 1024;
            suffix = 'G';
        } else {
            return formatSize(localBytes, suffix);
        }
        if (localBytes >= 1024) {
            localBytes = localBytes / 1024;
            suffix = 'T';
        } else {
            return formatSize(localBytes, suffix);
        }
        return formatSize(localBytes, suffix);
    }
    
    function formatSize(size, suffix) {
        var localSizeInt = parseInt(size);
        var resultStr = String(localSizeInt);
        if (localSizeInt < 1000 && suffix !== 'B' && size > localSizeInt) {
            var decimal = parseInt((size * 10) - (localSizeInt * 10));
            if (decimal > 0) {
                resultStr += '.';
                resultStr += decimal;
            }
        }
        return resultStr + suffix;
    }
    
    PlasmaCore.DataSource {
        id: dataSource
        
        property string downloadSource: 'network/interfaces/' + DeviceName + '/receiver/data'
        property string uploadSource: 'network/interfaces/' + DeviceName + '/transmitter/data'

        engine: 'systemmonitor'
        connectedSources: [downloadSource, uploadSource]
        interval: main.updateInterval
        
        onNewData: {
            var downBytes = dataSource.data[dataSource.downloadSource].value * 1024 || 0;
            var upBytes = dataSource.data[dataSource.uploadSource].value * 1024 || 0;
            
            //testing TODO delete
//             var downBytes = 1023;
//             var upBytes = 102*1024 + 3;
            
            connectionSpeedDownload.text = formatBytes(downBytes)
            connectionSpeedUpload.text = formatBytes(upBytes)
        }
        
        //for new and instantly connected sources
        onSourceAdded: {
            if (dataSource.downloadSource === source || dataSource.uploadSource === source) {
                dataSource.connectedSources.splice(0, 2);
                dataSource.connectedSources.push(dataSource.downloadSource);
                dataSource.connectedSources.push(dataSource.uploadSource);
            }
        }
    }
    
    PlasmaCore.SvgItem {
        id: connectionSvgIcon;

        anchors.centerIn: parent
        
        opacity: main.iconOpacity
        visible: !main.blurredIcons

        height: parent.height * (main.blurredIcons ? 0.3 : 1);
        width: height;
        elementId: ConnectionIcon;
        svg: PlasmaCore.Svg {
            multipleImages: true
            imagePath: 'icons/network'
        }
    }
    
    FastBlur {
        anchors.fill: parent
        source: connectionSvgIcon
        opacity: main.iconOpacity
        radius: 16
        visible: main.blurredIcons
    }
    
    Text {
        id: deviceNameText
        text: DeviceName
        
        anchors.top: parent.top
        anchors.left: parent.left
        
        color: theme.textColor
        opacity: 0.9
        
        font.italic: true
        font.pointSize: fontPointSize
        
        scale: paintedWidth > parent.width ? (parent.width / paintedWidth) : 1
        transformOrigin: Item.Left
        
        visible: main.showDeviceNames
    }
    
    Item {
        id: speedsContainer
        width: parent.width
        height: parent.height * (main.showDeviceNames ? (2/3) : 0.8)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: main.showDeviceNames ? 0 : parent.height * 0.1
        
        Text {
            id: uploadIcon
            anchors {
                left: parent.left;
                top: parent.top
            }
            text: '⬆'
            color: theme.textColor
            font.pointSize: fontPointSize
            visible: main.showDeviceNames
        }
        
        Text {
            id: connectionSpeedUpload
            anchors {
                right: parent.right;
                top: parent.top
            }
            text: '_'
            color: theme.textColor
            font.pointSize: fontPointSize
        }
        
        Text {
            id: downloadIcon
            anchors {
                left: parent.left;
                bottom: parent.bottom
            }
            text: '⬇'
            color: theme.textColor
            font.pointSize: fontPointSize
            visible: main.showDeviceNames
        }
        
        Text {
            id: connectionSpeedDownload
            anchors {
                right: parent.right;
                bottom: parent.bottom
            }
            text: '_'
            color: theme.textColor
            font.pointSize: fontPointSize
        }
    }
    
}