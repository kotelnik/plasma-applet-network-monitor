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

Item {
    id: ddwrtClient
    
    width: 0
    height: 0

    // DD-WRT hacky temporaries
    property double ddwrt_din: 0
    property double ddwrt_dout: 0
    property double last_ifin: 0
    property double last_ifout: 0
    property double last_ugmt: 0
    
    property int k: 0

    function queryDdWrt() {
        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE && request.status === 200) {
                
                var data=request.responseText.split("\n");
                var dateStr=data[0];
                //fake timezone cause the real value might confuse JS
                dateStr=dateStr.replace(/ [A-Z]+ /, ' ');
                var ugmt=(Date.parse(dateStr))/1000;

                data=data[1].split(/\s+|:/);
                while (data[0]!=parseInt(data[0])) {
                        data.shift();

                        if (0==data.length)
                            return 0;
                }
                var ifin=parseInt(data[0]);
                var ifout=parseInt(data[8]);

                var diff_ugmt  = ugmt - last_ugmt;
                var diff_ifin  = ifin - last_ifin;
                var diff_ifout = ifout - last_ifout;

                if (diff_ugmt == 0)
                    diff_ugmt = 1;  // avoid division by zero

                last_ugmt = ugmt;
                last_ifin = ifin;
                last_ifout = ifout;

                ddwrt_din = diff_ifin / diff_ugmt; // B / sec
                ddwrt_dout = diff_ifout / diff_ugmt; // B / sec
            }
        }

        var url = ddwrtHost + "/fetchif.cgi?vlan2"
        request.open('GET', url)
        request.setRequestHeader("Authorization", "Basic " + ddwrtKey)
        request.send()
    }

    Timer {
        interval: main.updateInterval;
        running: main.showDdWrt;
        repeat: true
        onTriggered: {
            queryDdWrt()
        }
    }
}
