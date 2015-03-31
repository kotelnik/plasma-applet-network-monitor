import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_iconOpacity: iconOpacity.value
    property alias cfg_blurredIcons: blurredIcons.checked
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
            value: 0.3
            tickmarksEnabled: true
            width: parent.width
            Layout.columnSpan: 2
        }

        CheckBox {
            id: blurredIcons
            Layout.columnSpan: 2
            text: i18n('Blurred icons')
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
