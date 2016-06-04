import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page
    Connections {
        target: contentItem
        onUseGpsChanged: gpsActive = contentItem.useGps
    }


    name: "DE - Tankerkönig"
    description: "Powered by www.tankerkönig.de"
    units: { "currency":"€", "distance": "km" }
    settings: Settings {
        name: "tankerkoenig"

        function save() {
            setValue( "radius", contentItem.searchRadius )
            setValue( "type", contentItem.type )
            setValue( "sort", main.sort )
            setValue( "gps", contentItem.useGps )
            setValue( "zipCode", contentItem.zipCode )
        }
        function load() {
            try {
                contentItem.searchRadius = getValue( "radius" )
                contentItem.type = getValue( "type" )
                main.sort = getValue( "sort" )
                contentItem.useGps = eval( getValue( "gps" ) )
                contentItem.zipCode = getValue( "zipCode" )
                favs.load()
            }
            catch( e ) {
                assign()
                load()
            }
        }
        function assign() {
            setValue( "radius", 1 )
            setValue( "type", "e5" )
            setValue( "sort", main.sort )
            setValue( "gps", false )
            setValue( "zipCode", "" )
        }
    }
    function prepare() {
        settings.load()
        pluginReady = true
    }

    function requestItems() {
        errorCode = 0
        itemsBusy = true
        items.clear()
        coverItems.clear()
        if( contentItem.useGps ) {
            gotItems( latitude, longitude )
        }
        else {
            var req = new XMLHttpRequest()
            req.open( "GET", "http://maps.google.com/maps/api/geocode/json?components=country:DE|postal_code:"+contentItem.zipCode )
            req.onreadystatechange = function() {
                if( req.readyState == 4 ) {
                    try {
                        var x = eval( req.responseText ).results[0].geometry.location
                        gotItems( x.lat, x.lng )
                    }
                    catch( e ) {
                        items.clear()
                        itemsBusy = false
                        errorCode = 2
                    }
                }
            }
            req.send()
        }
    }
    function gotItems( lat, lng ) {
        console.log(tankerkoenig_apikey)
        var req = new XMLHttpRequest()
        req.open( "GET", "https://creativecommons.tankerkoenig.de/json/list.php?sort=dist&lat="+lat+"&lng="+lng+"&rad="+contentItem.searchRadius+"&type="+contentItem.type+"&apikey="+tankerkoenig_apikey )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    console.log( req.responseText )
                    var x = eval( req.responseText )

                    x = x.stations
                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var itm = {
                            "stationID": o.id,
                            "stationName": o.name,
                            "stationPrice": o.price,
                            "stationAdress": capitalizeString(o.street) + (typeof(o.houseNumber) == "object" ? "" : " " + o.houseNumber) + ", " + o.postCode + " " + capitalizeString(o.place),
                            "stationDistance": o.dist*1000,
                            "customMessage": !o.isOpen?qsTr("Closed"):""
                        }
                        items.append( itm )
                  }
                    sort()
                    itemsBusy = false
                    errorCode = items.count < 1 ? 1 : 0
                }
                catch ( e ) {
                    items.clear()
                    itemsBusy = false
                    errorCode = 3
                }
            }
        }
        req.send()
    }

    function requestStation( id ) {
        stationBusy = true
        station = {}
        stationPage = pageStack.push( "../GasStation.qml", {stationId:id} )
        var req = new XMLHttpRequest()
        req.open( "GET", "https://creativecommons.tankerkoenig.de/json/detail.php?id="+id+"&apikey="+tankerkoenig_apikey )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                console.log( req.responseText )
                //try {
                    var x = eval( req.responseText )
                    x = x.station
                    var info = [
                        { "title":qsTr("Brand"), "text":x.brand },
                        { "title":qsTr("State"), "text":x.isOpen?qsTr("Open"):qsTr("Closed") }
                    ]
                    var price = [
                        { "title":"Super",       "price":x.e5, "sz":Theme.fontSizeLarge },
                        { "title":"Super E10", "price": x.e10, "sz":Theme.fontSizeLarge },
                        { "title":"Diesel", "price": x.diesel, "sz":Theme.fontSizeLarge }
                    ]
                    var times = []
                    for( var i = 0; i < x.openingTimes.length; i++ ) {
                        times[times.length] = { "title":x.openingTimes[i].text, "text":stripSeconds(x.openingTimes[i].start) + " - " + stripSeconds(x.openingTimes[i].end), "tf":true }
                    }
                    station = {
                        "stationID":x.id,
                        "stationName":x.name,
                        "stationAdress": {
                            "street":x.street + " " + (typeof(x.houseNumber) == "object" ? "" : x.houseNumber),
                            "county":x.postCode + " " + x.place,
                            "country":"",
                            "latitude":station.lat,
                            "longitude":station.lng
                        },
                        "content": [
                            { "title":qsTr("Info"), "items": info },
                            { "title":qsTr("Prices"), "items": price },
                            { "title":qsTr("Opening Times"), "items": times }
                        ]
                    }
                    stationBusy = false
                try{}
                catch ( e ) {
                    station = {}
                    stationBusy = false
                }
                log( station)
                stationPage.station = station
            }
        }
        req.send()
    }






    content: Component {
        Column {
            property alias searchRadius: sradius.value
            property alias useGps: gpsSwitch.checked
            property alias zipCode: postalCode.text
            property string type: "e10"

            SectionHeader {
                text: qsTr("Fuel Type")
            }
            Row {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall
                Button {
                    text: "Super (E5)"
                    width: parent.width/3 - parent.spacing
                    down: type == "e5"
                    onClicked: type = "e5"
                }
                Button {
                    text: "Super (E10)"
                    width: parent.width/3 - parent.spacing
                    down: type == "e10"
                    onClicked: type = "e10"
                }
                Button {
                    text: "Diesel"
                    width: parent.width/3
                    down: type == "diesel"
                    onClicked: type = "diesel"
                }
            }

            SectionHeader {
                text: qsTr("Search Radius")
            }
            Slider {
                id: sradius
                width: parent.width
                minimumValue: 1
                maximumValue: 25
                stepSize: 1
                value: 1
                //onValueChanged: searchRadius = value
                valueText: value+" km"
            }

            SectionHeader {
                text: qsTr("Location")
            }

            TextSwitch {
                id: gpsSwitch
                text: qsTr("Use GPS")
            }

            TextField {
                id: postalCode
                placeholderText: qsTr("Zip Code")
                label: placeholderText
                width: parent.width
                readOnly: useGps
                onTextChanged: zipCode = text
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: RegExpValidator { regExp: /\d{5}/ }
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: focus = false
            }
        }
    }
}

