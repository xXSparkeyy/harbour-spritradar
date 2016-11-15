import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "AT - spritpreisrechner.at"
    description: "Powered by E-Control"
    units: { "currency":"€", "distance": "km" }
    countryCode: "de"
    type: "DIE"
    types: ["SUP","DIE"]
    names: [qsTr("e5"),qsTr("diesel")]

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
                useGps = eval( getValue( "gps" ) )
                contentItem.hideClosed = eval( getValue( "hideClosed" ) )
                address = getValue( "address" )
                favs.load()
            }
            catch( e ) {
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
        else getItemsByAddress("AT", getItems)
    }

    function getItems( lat, lng ) {
        console.log("lat: " + lat + ", lng: " +lng);
        var req = new XMLHttpRequest()
        req.open( "POST", "http://www.spritpreisrechner.at/ts/GasStationServlet" )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    //console.log("response text: " + req.responseText )
                    var x = eval( req.responseText )

                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var stationPrice = o.spritPrice[0].amount;
                        if( contentItem.hideClosed && !o.open || stationPrice <= 0.0) continue

                        var itm = {
                            "stationID": "xxx",
                            "stationName": o.gasStationName,
                            "stationPrice": stationPrice,
                            "stationAdress": capitalizeString(o.address) + ", " + o.postalCode + " " + capitalizeString(o.city),
                            "stationDistance": o.distance*1000,
                            "customMessage": !o.open?qsTr("Closed"):""
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
        var data = [contentItem.hideClosed? "" : "checked", type, lng, lat, lng, lat];
        var params = JSON.stringify(data);

        req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        req.send("data=" + params)
    }

    function requestStation( id ) {
        console.log("requestStation not implemented")
    }

    function getPriceForFav( id ) {
        console.log("getPriceForFav() not implemented")
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

