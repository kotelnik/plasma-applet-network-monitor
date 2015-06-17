import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_iconOpacity: iconOpacity.value
    property alias cfg_iconBlur: iconBlur.value
    property alias cfg_showDeviceNames: showDeviceNames.checked

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        
        Label {
            text: i18n('Icon opacity:')
            Layout.alignment: Qt.AlignVCenter|Qt.AlignLeft
            Layout.columnSpan: 2
        }
        Slider {
            id: iconOpacity
            stepSize: 0.05
            minimumValue: 0
            tickmarksEnabled: true
            width: parent.width
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Icon blur:')
            Layout.alignment: Qt.AlignVCenter|Qt.AlignLeft
            Layout.columnSpan: 2
        }
        Slider {
            id: iconBlur
            stepSize: 1
            minimumValue: 0
            maximumValue: 20
            width: parent.width
            Layout.columnSpan: 2
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        CheckBox {
            id: showDeviceNames
            Layout.columnSpan: 2
            text: i18n('Show device names')
        }
        
    }
    
}
