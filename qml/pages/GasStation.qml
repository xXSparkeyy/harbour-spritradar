import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    clip: true
    property string stationId: ""
    onStationIdChanged: {
        station = eval( "{\"station\":{\"id\":\"0\",\"name\":\"Loading...\",\"brand\":\"\",\"street\":\"\",\"houseNumber\":null,\"postCode\":\"\",\"place\":\"\",\"overrides\":[],\"isOpen\":false,\"e5\":0.000,\"e10\":0.000,\"diesel\":0.000,\"lat\":0,\"lng\":0,\"state\":null,\"openingTimes\":[]}}" ).station
        stationLoading = true
        var req = new XMLHttpRequest()
        req.open( "GET", "https://creativecommons.tankerkoenig.de/json/detail.php?id="+stationId+"&apikey=" + apikey )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                stationLoading = false
                station = eval( req.responseText ).station
                }
        }
        req.send()
    }

    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            active: stationLoading
            MenuItem {
                text: ( isFav( stationId ) ? qsTr( "Unset as Favourite" ) : qsTr( "Set as Favourite" ) )
                onClicked: ( isFav( stationId ) ? unsetFav : setFav )(stationId, station.name)
            }
        }

        Column {
            width: parent.width
            PageHeader {
                title: station.name
            }
            BackgroundItem {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: Qt.openUrlExternally( "geo:"+station.lat+","+station.lng )
                id: usgszfgasz
                Text {
                    //Adresse
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    anchors.fill: parent
                    text: station.street+" "+(typeof(station.houseNumber) == "object"?"":station.houseNumber)+(station.id=="0"?"":", ")+station.postCode+" "+station.place
                    color: usgszfgasz.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: 0
                    verticalAlignment: Text.AlignVCenter
                }
            }
            SectionHeader {
                text: qsTr("Prices")
            }
            ListText {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                title: "Super E5"
                text: station.e5+"€"
            }
            ListText {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                title: "Super E10"
                text: station.e10+"€"
            }
            ListText {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                title: "Diesel"
                text: station.diesel+"€"
            }
            SectionHeader {
                text: qsTr("Opening Times")
            }
            ListText {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                title: station.isOpen ? qsTr("Open") : qsTr("Closed")
            }
            Item {
                height: Theme.paddingSmall
                width: 1
            }
            Repeater {
                //openin times
                model: station.openingTimes.length
                ListText {
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    anchors.horizontalCenter: parent.horizontalCenter
                    title: station.openingTimes[index].text
                    text: station.openingTimes[index].start+" - "+station.openingTimes[index].end
                }
            }
        }
    }
    BusyIndicator {
        anchors.centerIn: parent
        running: visible
        size: BusyIndicatorSize.Large
        visible: stationLoading
    }
}
/*
{
  "license": "CC BY 4.0 -  http:\/\/creativecommons.tankerkoenig.de",
  "data": "MTS-K",
  "station": {
    "id": "005056ba-7cb6-1ed2-bceb-90e59ad2cd35",
    "name": "star Tankstelle",
    "brand": "STAR",
    "street": "Gelsdorfer Stra\u00dfe",
    "houseNumber": "2-4",
    "postCode": 53340,
    "place": "Meckenheim",
    "overrides": [

    ],
    "openUntil": 1440100800,
    "isOpen": true,
    "e5": 1.339,
    "e10": 1.319,
    "diesel": 1.069,
    "lat": 50.61793,
    "lng": 7.02484,
    "state": null,
    "openingTimes": [
      {
        "text": "Mo-Fr",
        "start": "06:00:00",
        "end": "22:00:00"
      },
      {
        "text": "Samstag",
        "start": "07:00:00",
        "end": "22:00:00"
      },
      {
        "text": "Sonntag",
        "start": "08:00:00",
        "end": "22:00:00"
      }
    ]
  }
}
*/
