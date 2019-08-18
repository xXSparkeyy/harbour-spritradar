import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "AT - spritpreisrechner.at"
    description: "Powered by E-Control"
    units: { "currency":"€", "distance": "km" }
    countryCode: "at"
    type: "DIE"
    types: ["SUP","DIE","GAS"]
    names: [qsTr("e5"),qsTr("diesel"),qsTr("Gas")]
    supportsFavs: false

    property variant stations: []
    property string url: "https://api.e-control.at/sprit/1.0/search/gas-stations/by-address"

    settings: Settings {
        name: "spritpreisrechner"

        function save() {
            setValue( "radius", searchRadius )
            setValue( "type", type )
            setValue( "sort", main.sort )
            setValue( "gps", useGps )
            setValue( "hideClosed", contentItem.hideClosed )
            setValue( "address", address )
        }
        function load() {
           try {
                searchRadius = getValue( "radius" )
                type = getValue( "type" )
                main.sort = getValue( "sort" )
                useGps = JSON.parse( getValue( "gps" ) )
                contentItem.hideClosed = JSON.parse( getValue( "hideClosed" ) )
                address = getValue( "address" )
                favs.load()
            }
            catch(e) {
console.log(e.message)
                assign()
                load()
            }
        }
        function assign() {
            setValue( "radius", 1 )
            setValue( "type", "SUP95" )
            setValue( "sort", main.sort )
            setValue( "gps", false )
            setValue( "hideClosed", false )
            setValue( "address", "" )

        }
    }

    function prepare() {
        settings.load()
        pluginReady = true
    }

    function requestItems() {
        prepareItems()
        if( useGps ) getItems( latitude, longitude )
        else getItemsByAddress(getItems)
    }

    function getItems( lat, lng ) {
        var req = new XMLHttpRequest()
        req.open( "GET", url+"?latitude="+lat+"&longitude="+lng+"&fuelType="+type+"&includeClosed="+(contentItem.hideClosed? "false" : "true") )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    var x = JSON.parse( req.responseText )
                    stations = x;

                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var l = o.location
                        if( o.prices.length == 0 ) continue
                        var stationPrice = o.prices[0].amount;
                        if( contentItem.hideClosed && !o.open || stationPrice <= 0.0) continue
                        var itm = {
                            "stationID": i,//o.id,
                            "stationName": o.name,
                            "stationPrice": stationPrice,
                            "stationAdress": capitalizeString(l.address) + ", " + l.postalCode + " " + capitalizeString(l.city),
                            "latitude": l.latitude,
                            "longitude": l.longitude,
                            "stationDistance": o.distance*1000,
                            "customMessage": !o.open?qsTr("Closed"):""
                        }
                        items.append( itm )
                  }
                    sort()
                    itemsBusy = false
                    errorCode = items.count < 1 ? 1 : 0
                }
                catch(e) {
console.log(e.message)
                    items.clear()
                    itemsBusy = false
                    errorCode = 3
                }
            }
       }
        req.send()
    }

    function requestStation( id ) {
        try {
            stationBusy = true
            station = {}
            stationPage = pageStack.push( "../GasStation.qml", {stationId:id} )
            var x = stations[id]
            var info = [
                { "title":qsTr("State"), "text":x.open?qsTr("Open"):qsTr("Closed") }
            ]
            var times = []
            for( var i = 0; i < x.openingHours.length; i++ ) {
                times[i] = { "title":x.openingHours[i].label, "text":stripSeconds(x.openingHours[i].from) + " - " + stripSeconds(x.openingHours[i].to), "tf":true, "order": x.openingHours[i].order }
            }
            times.sort( function(a,b) { return a.order-b.order } )

            station = {
                "stationID":id,
                "stationName":x.name,
                "stationAdress": {
                    "street": x.location.address,
                    "county":x.location.city,
                    "country":"",
                    "latitude":x.location.latitude,
                    "longitude":x.location.longitude
                },
                "content": [
                    { "title":qsTr("Info"), "items": info },
                    { "title":qsTr("Opening Times"), "items": times }
                ]
            }

        }
        catch(e) {
console.log(e.message)
            console.log( e )
            station = {}
            stationBusy = false
        }
        stationPage.station = station
        stationBusy = false
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

