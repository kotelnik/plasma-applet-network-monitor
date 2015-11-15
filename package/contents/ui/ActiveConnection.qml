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
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/helper.js" as Helper


Item {
    id: activeConnection
    
    width: main.itemWidth
    height: main.itemHeight
    
    property int oneLineMargin: 5
    
    property double fontPixelSize: height * 0.27 * (main.layoutType === 0 ? 1 : main.layoutType === 1 ? 1.4 : main.layoutType === 2 ? 1.85 : 3.6)
    property int graphGranularity: 20 * main.itemAspectRatio
    property bool noConnection: DeviceName === '_'
    
    property bool ddwrtConnection: DeviceName === 'DD-WRT'

    function formatBytes(bytes) {
        if (showBits) {
            return Helper.transformNumber(bytes * 8, 1000, 3, ['b', 'K', 'M', 'G', 'T', 'P'])
        }
        return Helper.transformNumber(bytes, 1024, 3, ['B', 'K', 'M', 'G', 'T', 'P'])
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
        
        Helper.addSpeedData(downBytes, downloadHistoryGraphModel, graphGranularity, 1)
        Helper.addSpeedData(upBytes, uploadHistoryGraphModel, graphGranularity, uploadHistoryGraphModel.maxBytes === 0 ? 1 : uploadHistoryGraphModel.maxBytes / downloadHistoryGraphModel.maxBytes)
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
    
    PlasmaComponents.Label {
        id: deviceNameText
        text: DeviceName
        
        anchors.top: parent.top
        anchors.left: parent.left
        
        verticalAlignment: Text.AlignTop
        
        opacity: 0.9
        
        font.italic: true
        font.pixelSize: fontPixelSize
        
        scale: paintedWidth > parent.width ? (parent.width / paintedWidth) : 1
        transformOrigin: Item.Left
        
        visible: !noConnection && main.layoutType === 0
    }
    
    Item {
        id: speedsContainer
        //width: parent.width
        height: parent.height * (main.layoutType === 0 ? (2/3) : main.layoutType === 1 ? 0.8 : 1)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: main.layoutType !== 1 ? 0 : parent.height * 0.1
        anchors.left: parent.left
        anchors.right: parent.right
        
        visible: !noConnection
        
        PlasmaComponents.Label {
            id: uploadIcon
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: main.layoutType === 3 ? 0 : - fontPixelSize * 0.58
            }
            text: '⬆'
            font.pixelSize: fontPixelSize
            visible: main.layoutType === 0
        }
        
        PlasmaComponents.Label {
            id: connectionSpeedUpload
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: uploadIcon.anchors.verticalCenterOffset
            }
            text: '_'
            font.pixelSize: fontPixelSize
            visible: main.layoutType !== 3 || !hideUpload
        }
        
        PlasmaComponents.Label {
            id: downloadIcon
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -uploadIcon.anchors.verticalCenterOffset
            }
            text: '⬇'
            font.pixelSize: fontPixelSize
            visible: main.layoutType === 0
        }
        
        PlasmaComponents.Label {
            id: connectionSpeedDownload
            anchors {
                right: parent.right
                rightMargin: (main.layoutType === 3 && !hideUpload) ? parent.width / 2 - oneLineMargin : 0
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -uploadIcon.anchors.verticalCenterOffset
            }
            text: '_'
            font.pixelSize: fontPixelSize
            visible: main.layoutType !== 3 || !hideDownload
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
