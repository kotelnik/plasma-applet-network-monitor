/***************************************************************************
 *   Copyright (C) 2013 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

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
