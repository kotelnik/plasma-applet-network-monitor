import QtQuick 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_showLo: showLo.checked
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_historyGraphsEnabled: historyGraphsEnabled.checked

    GridLayout {
        Layout.fillWidth: true
        columns: 2

        CheckBox {
            id: showLo
            Layout.columnSpan: 2
            text: i18n('Show loopback')
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        Label {
            text: i18n('Update interval:')
            Layout.alignment: Qt.AlignRight
        }
        SpinBox {
            id: updateIntervalSpinBox
            decimals: 1
            stepSize: 0.1
            minimumValue: 0.1
            suffix: i18nc('Abbreviation for seconds', 's')
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
        CheckBox {
            id: historyGraphsEnabled
            Layout.columnSpan: 2
            text: i18n('Enable history graphs')
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }
        
    }
    
}
