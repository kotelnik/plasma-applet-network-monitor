import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_historyGraphsEnabled: historyGraphsEnabled.checked
    property alias cfg_ddwrtHost: ddwrtHost.text
    property alias cfg_ddwrtUser: ddwrtUser.text
    property alias cfg_ddwrtPassword: ddwrtPassword.text

    GridLayout {
        Layout.fillWidth: true
        columns: 2

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

        Label {
            text: i18n('DD-WRT host:')
            Layout.alignment: Qt.AlignRight
        }

        TextField {
            id: ddwrtHost
            placeholderText: i18n('http://192.168.178.23')
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('DD-WRT user:')
            Layout.alignment: Qt.AlignRight
        }

        TextField {
            id: ddwrtUser
            placeholderText: i18n('admin')
        }

        Item {
            width: 2
            height: 10
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('DD-WRT password:')
            Layout.alignment: Qt.AlignRight
        }

        TextField {
            id: ddwrtPassword
            placeholderText: i18n('password')
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
