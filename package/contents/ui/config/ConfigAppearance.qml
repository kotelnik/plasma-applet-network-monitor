import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_iconOpacity: iconOpacity.value
    property alias cfg_iconBlur: iconBlur.value
    property int cfg_layoutType
    property alias cfg_baseSizeMultiplier: baseSizeMultiplier.value
    property alias cfg_showUploadDownload: showUploadDownload.currentIndex
    
    onCfg_layoutTypeChanged: {
        switch (cfg_layoutType) {
        case 0:
            layoutTypeGroup.current = layoutTypeRadioFullView;
            break;
        case 1:
            layoutTypeGroup.current = layoutTypeRadioNoDeviceNames;
            break;
        case 2:
            layoutTypeGroup.current = layoutTypeRadioBigNumbers;
            break;
        case 3:
            layoutTypeGroup.current = layoutTypeRadioOneLine;
            break;
        default:
        }
    }
    
    Component.onCompleted: {
        cfg_layoutTypeChanged()
    }

    ExclusiveGroup {
        id: layoutTypeGroup
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        
        Label {
            text: i18n('Icon opacity:')
            Layout.alignment: Qt.AlignVCenter|Qt.AlignLeft
            Layout.columnSpan: 3
        }
        Slider {
            id: iconOpacity
            stepSize: 0.05
            minimumValue: 0
            tickmarksEnabled: true
            width: parent.width
            Layout.columnSpan: 3
        }
        
        Label {
            text: i18n('Icon blur:')
            Layout.alignment: Qt.AlignVCenter|Qt.AlignLeft
            Layout.columnSpan: 3
        }
        Slider {
            id: iconBlur
            stepSize: 1
            minimumValue: 0
            maximumValue: 20
            width: parent.width
            Layout.columnSpan: 3
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 3
        }
        
        Label {
            text: i18n('Layout type:')
            Layout.alignment: Qt.AlignVCenter|Qt.AlignRight
        }
        RadioButton {
            id: layoutTypeRadioFullView
            exclusiveGroup: layoutTypeGroup
            text: i18n("Full view")
            onCheckedChanged: if (checked) cfg_layoutType = 0;
            Layout.columnSpan: 2
        }
        Item {
            width: 2
            height: 2
            Layout.rowSpan: 3
        }
        RadioButton {
            id: layoutTypeRadioNoDeviceNames
            exclusiveGroup: layoutTypeGroup
            text: i18n("No device names")
            onCheckedChanged: if (checked) cfg_layoutType = 1;
            Layout.columnSpan: 2
        }
        RadioButton {
            id: layoutTypeRadioBigNumbers
            exclusiveGroup: layoutTypeGroup
            text: i18n("Big numbers")
            onCheckedChanged: if (checked) cfg_layoutType = 2;
            Layout.columnSpan: 2
        }
        RadioButton {
            id: layoutTypeRadioOneLine
            exclusiveGroup: layoutTypeGroup
            text: i18n("One line")
            onCheckedChanged: if (checked) cfg_layoutType = 3;
        }
        ComboBox {
            id: showUploadDownload
            Layout.preferredWidth: 170
            model: ['Download and upload', 'Download only', 'Upload only']
            enabled: layoutTypeRadioOneLine.checked
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 3
        }
        
        Label {
            text: i18n('Wrapping coefficient:')
            Layout.alignment: Qt.AlignVCenter|Qt.AlignLeft
        }
        SpinBox {
            id: baseSizeMultiplier
            decimals: 2
            stepSize: 0.1
            minimumValue: 0.01
            maximumValue: 50
            Layout.columnSpan: 2
        }
        
    }
    
}
