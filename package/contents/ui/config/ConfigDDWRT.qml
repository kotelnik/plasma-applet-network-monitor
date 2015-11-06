import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

Item {
    width: childrenRect.width
    height: childrenRect.height
    
    property int textfieldWidth: 200
    
    property alias cfg_ddwrtHost: ddwrtHost.text
    property alias cfg_ddwrtUser: ddwrtUser.text
    property alias cfg_ddwrtPassword: ddwrtPassword.text
    
    GridLayout {
        Layout.fillWidth: true
        columns: 3

        Label {
            text: i18n('Hostname:')
            Layout.alignment: Qt.AlignRight
        }

        TextField {
            id: ddwrtHost
            placeholderText: i18n('e.g. http://192.168.178.23')
            Layout.preferredWidth: textfieldWidth
            Layout.columnSpan: 2
        }
        
        Item {
            width: 2
            height: 10
            Layout.columnSpan: 3
        }
        
        Label {
            text: i18n('Basic Authentication')
            Layout.alignment: Qt.AlignLeft
            font.bold: true
            Layout.columnSpan: 3
        }
        
        Label {
            text: i18n('Username:')
            Layout.alignment: Qt.AlignRight
        }

        TextField {
            id: ddwrtUser
            Layout.preferredWidth: textfieldWidth
            Layout.columnSpan: 2
        }

        Label {
            text: i18n('Password:')
            Layout.alignment: Qt.AlignRight
        }

        TextField {
            id: ddwrtPassword
            echoMode: showPasswordCharacters.checked ? TextInput.Normal : TextInput.Password
            Layout.preferredWidth: textfieldWidth
        }
        
        CheckBox {
            id: showPasswordCharacters
            text: i18n('Show Characters')
        }
        
    }
    
}
