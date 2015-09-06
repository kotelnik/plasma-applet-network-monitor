import QtQuick 2.2
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n('General')
         icon: Qt.resolvedUrl('../images/network-monitor.svg')
         source: 'config/ConfigGeneral.qml'
    }
    ConfigCategory {
         name: i18n('Filter')
         icon: 'preferences-system-other'
         source: 'config/ConfigFilter.qml'
    }
    ConfigCategory {
         name: i18n('Appearance')
         icon: 'preferences-desktop-color'
         source: 'config/ConfigAppearance.qml'
    }
    ConfigCategory {
         name: i18n('DD-WRT')
         icon: Qt.resolvedUrl('../images/dd-wrt.png')
         source: 'config/ConfigDDWRT.qml'
    }
}
