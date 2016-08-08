import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "DE - Tankerkönig"
    description: "Powered by www.tankerkönig.de"
    units: { "currency":"€", "distance": "km" }
    countryCode: "-"
    type: "e10"
    types: ["e5","e10","diesel"]
    names: [qsTr("e5"),qsTr("e10"),qsTr("diesel")]

    settings: Settings {
        name: "tankerkoenig"

        function save() {
            setValue( "radius", searchRadius )
            setValue( "type", type )
            setValue( "sort", main.sort )
            setValue( "gps", useGps )
            setValue( "hideClosed", contentItem.hideClosed )
            setValue( "zipCode", zipCode )
        }
        function load() {
            try {
                searchRadius = getValue( "radius" )
                type = getValue( "type" )
                main.sort = getValue( "sort" )
                useGps = eval( getValue( "gps" ) )
                contentItem.hideClosed = eval( getValue( "hideClosed" ) )
                zipCode = getValue( "zipCode" )
                names = [qsTr("e5"),qsTr("e10"),qsTr("diesel")]
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
            setValue( "hideClosed", false )
            setValue( "zipCode", "" )

        }
    }

    function prepare() {
        settings.load()
        pluginReady = true
    }

    function requestItems() {
        prepareItems()
        if( useGps ) getItems( latitude, longitude )
        else getItemsByPostalCode("DE", getItems)
    }

    function getItems( lat, lng ) {
        var req = new XMLHttpRequest()
        req.open( "GET", "https://creativecommons.tankerkoenig.de/json/list.php?sort=dist&lat="+lat+"&lng="+lng+"&rad="+searchRadius+"&type="+type+"&apikey="+tankerkoenig_apikey )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    //console.log( req.responseText )
                    var x = eval( req.responseText )

                    x = x.stations
                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        if( contentItem.hideClosed && !o.isOpen ) continue
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
                try {
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
                            "latitude":x.lat,
                            "longitude":x.lng
                        },
                        "content": [
                            { "title":qsTr("Info"), "items": info },
                            { "title":qsTr("Prices"), "items": price },
                            { "title":qsTr("Opening Times"), "items": times }
                        ]
                    }
                    stationBusy = false
                }
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

    radiusSlider {
        maximumValue: 20
    }

    content: Component {
        Column {
            property alias hideClosed: hideClosedButton.checked

            TextSwitch {
                id: hideClosedButton
                width: parent.width
                text: qsTr("Hide Closed")
            }
        }
}
}

