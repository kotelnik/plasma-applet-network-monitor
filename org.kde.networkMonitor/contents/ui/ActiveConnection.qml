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
import org.kde.plasma.core 2.0 as PlasmaCore
import "../code/helper.js" as Helper


Item {
    id: activeConnection
    
    width: main.itemWidth
    height: main.itemHeight
    
    property int oneLineMargin: 5
    
    property double fontPointSize: height * 0.195 * (main.layoutType === 0 ? 1 : main.layoutType === 1 ? 1.25 : main.layoutType === 2 ? 1.75 : 3.25)
    property int graphGranularity: 20 * main.itemAspectRatio
    property bool noConnection: DeviceName === '_'
    
    property bool ddwrtConnection: DeviceName === 'DD-WRT'

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
    
    ListModel {
        id: downloadHistoryGraphModel
        
        property real maxBytes: 0
        property int maxBytesModelIndex: 0
        property real lowerMaxBytesInMs: -1
    }
    
    ListModel {
        id: uploadHistoryGraphModel
        
        property real maxBytes: 0
        property int maxBytesModelIndex: 0
        property real lowerMaxBytesInMs: -1
    }
    
    PlasmaCore.DataSource {
        id: dataSource
        
        property string downloadSource: ddwrtConnection ? '' : 'network/interfaces/' + DeviceName + '/receiver/data'
        property string uploadSource: ddwrtConnection ? '' : 'network/interfaces/' + DeviceName + '/transmitter/data'

        engine: 'systemmonitor'
        connectedSources: [downloadSource, uploadSource]
        interval: ddwrtConnection ? 0 : main.updateInterval
        
        onNewData: {
            var downData = dataSource.data[downloadSource]
            var upData = dataSource.data[uploadSource]
            if (downData === undefined || upData === undefined) {
                return
            }

            var downBytes = downData.value * 1024 || 0;
            var upBytes = upData.value * 1024 || 0;
            
            updateSpeeds(downBytes, upBytes, sourceName === dataSource.downloadSource)
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
    
    function updateSpeeds(downBytes, upBytes, canUpdateHistoryGraph) {
        connectionSpeedDownload.text = formatBytes(downBytes)
        connectionSpeedUpload.text = formatBytes(upBytes)
        
        if (main.layoutType === 3) {
            connectionSpeedDownload.text += '⬇'
            connectionSpeedUpload.text += '⬆'
        }
        
        //
        // history graph
        //
        if (!historyGraphsEnabled || !canUpdateHistoryGraph) {
            return
        }
        
        Helper.addSpeedData(downBytes, downloadHistoryGraphModel, graphGranularity, main.itemHeight, 1)
        Helper.addSpeedData(upBytes, uploadHistoryGraphModel, graphGranularity, main.itemHeight, uploadHistoryGraphModel.maxBytes === 0 ? 1 : uploadHistoryGraphModel.maxBytes / downloadHistoryGraphModel.maxBytes)
    }
    
    Timer {
        interval: main.updateInterval;
        running: ddwrtConnection;
        repeat: true
        onTriggered: {
            updateSpeeds(ddWrt.ddwrt_din, ddWrt.ddwrt_dout, true)
        }
    }
    
    Image {
        id: noConnectionIcon;

        anchors.centerIn: parent
        
        opacity: main.iconOpacity
        visible: false

        height: main.itemHeight * (1 - (main.iconBlur / 30));
        width: height;
        
        source: '../images/network-disconnect.svg'
    }
    
    PlasmaCore.SvgItem {
        id: connectionSvgIcon;

        visible: false

        height: main.itemHeight * (1 - (main.iconBlur / 30));
        width: height;
        
        anchors.centerIn: parent
        
        elementId: ConnectionIcon;
        svg: PlasmaCore.Svg {
            multipleImages: true
            imagePath: 'icons/network'
        }
    }
    
    FastBlur {
        //anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) / 2 + (main.layoutType === 3 ? width / 2 + oneLineMargin : 0)
        
        height: main.itemHeight
        width: height
        source: noConnection ? noConnectionIcon : connectionSvgIcon
        opacity: main.iconOpacity
        radius: main.iconBlur
    }
    
    HistoryGraph {
        listViewModel: downloadHistoryGraphModel
        barColor: theme.highlightColor
        opacity: 0.5
        visible: !noConnection && historyGraphsEnabled
    }
    
    HistoryGraph {
        listViewModel: uploadHistoryGraphModel
        barColor: '#FF0000'
        opacity: 0.5
        visible: !noConnection && historyGraphsEnabled
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
        
        visible: !noConnection && main.layoutType === 0
    }
    
    Item {
        id: speedsContainer
        width: parent.width
        height: parent.height * (main.layoutType === 0 ? (2/3) : main.layoutType === 1 ? 0.8 : 1)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: main.layoutType !== 1 ? 0 : parent.height * 0.1
        
        visible: !noConnection
        
        Text {
            id: uploadIcon
            anchors {
                left: parent.left
                top: parent.top
            }
            text: '⬆'
            color: theme.textColor
            font.pointSize: fontPointSize
            visible: main.layoutType === 0
        }
        
        Text {
            id: connectionSpeedUpload
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: main.layoutType === 3 ? 0 : - (parent.height - fontPointSize * 1.8) / 2 
            }
            text: '_'
            color: theme.textColor
            font.pointSize: fontPointSize
        }
        
        Text {
            id: downloadIcon
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            text: '⬇'
            color: theme.textColor
            font.pointSize: fontPointSize
            visible: main.layoutType === 0
        }
        
        Text {
            id: connectionSpeedDownload
            anchors {
                right: parent.right
                rightMargin: main.layoutType === 3 ? parent.width / 2 - oneLineMargin : 0
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: main.layoutType === 3 ? 0 : (parent.height - fontPointSize * 1.8) / 2
            }
            text: '_'
            color: theme.textColor
            font.pointSize: fontPointSize
        }
    }
    
    DropShadow {
        anchors.fill: speedsContainer
        radius: 3
        samples: 8
        spread: 0.8
        fast: true
        color: theme.backgroundColor
        source: speedsContainer
        visible: !noConnection && historyGraphsEnabled
    }
    
}
