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
    supportsFavs: false

    property variant stations: []

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
        var req = new XMLHttpRequest()
        req.open( "POST", "http://www.spritpreisrechner.at/ts/GasStationServlet" )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    var x = eval( req.responseText )
                    stations = x;

                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var stationPrice = o.spritPrice[0].amount;
                        if( contentItem.hideClosed && !o.open || stationPrice <= 0.0) continue
                        var itm = {
                            "stationID": i,
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
                times[i] = { "title":x.openingHours[i].day.dayLabel, "text":stripSeconds(x.openingHours[i].beginn) + " - " + stripSeconds(x.openingHours[i].end), "tf":true, "order": x.openingHours[i].day.order }
            }
            times.sort( function(a,b) { return a.order-b.order } )

            station = {
                "stationID":id,
                "stationName":x.gasStationName,
                "stationAdress": {
                    "street": x.address,
                    "county":x.city,
                    "country":"",
                    "latitude":x.latitude,
                    "longitude":x.longitude
                },
                "content": [
                    { "title":qsTr("Info"), "items": info },
                    { "title":qsTr("Opening Times"), "items": times }
                ]
            }

        }
        catch ( e ) {
            station = {}
            stationBusy = false
        }
        stationPage.station = station
        stationBusy = false
    }

    /*{
    "access": ,
    "address": Rechte Wienzeile 43,
    "automat": false,
    "bar": true,
    "city": wien,
    "club": false,
    "clubCard": ,
    "companionship": false,
    "distance": 1.73,
    "errorCode": 1,
    "errorItems":
    },
    "fax": ,
    "gasStationName": SPRIT-INN,
    "kredit": true,
    "ladeLeistungen": ,
    "ladeleistungNormal": false,
    "ladeleistungSchnell": false,
    "ladetechniken": ,
    "latitude": 48.1963317,
    "longitude": 16.3587045,
    "maestro": true,
    "mail": ,
    "open": false,
    "openingHours": {
      "0": {
        "beginn": 06:00,
        "day": {
          "day": MI,
          "dayLabel": Mittwoch,
          "errorCode": 0,
          "errorItems":
    },
          "order": 3
    },
        "end": 20:00
    },
      "1": {
        "beginn": 06:00,
        "day": {
          "day": FR,
          "dayLabel": Freitag,
          "errorCode": 0,
          "errorItems":
    },
          "order": 5
    },
        "end": 20:00
    },
      "2": {
        "beginn": 06:00,
        "day": {
          "day": DO,
          "dayLabel": Donnerstag,
          "errorCode": 0,
          "errorItems":
    },
          "order": 4
    },
        "end": 20:00
    },
      "3": {
        "beginn": 08:00,
        "day": {
          "day": SO,
          "dayLabel": Sonntag,
          "errorCode": 0,
          "errorItems":
    },
          "order": 7
    },
        "end": 20:00
    },
      "4": {
        "beginn": 08:00,
        "day": {
          "day": FE,
          "dayLabel": Feiertag,
          "errorCode": 0,
          "errorItems":
    },
          "order": 8
    },
        "end": 20:00
    },
      "5": {
        "beginn": 06:00,
        "day": {
          "day": MO,
          "dayLabel": Montag,
          "errorCode": 0,
          "errorItems":
    },
          "order": 1
    },
        "end": 20:00
    },
      "6": {
        "beginn": 06:00,
        "day": {
          "day": SA,
          "dayLabel": Samstag,
          "errorCode": 0,
          "errorItems":
    },
          "order": 6
    },
        "end": 20:00
    },
      "7": {
        "beginn": 06:00,
        "day": {
          "day": DI,
          "dayLabel": Dienstag,
          "errorCode": 0,
          "errorItems":
    },
          "order": 2
    },
        "end": 20:00
    }
    },
    "payMethod": ,
    "postalCode": 1050,
    "priceSearchDisabled": false,
    "self": false,
    "service": true,
    "serviceText": Autoreinigung Handwäsche Innen & Außen, Reifendienst, Neureifen, Reifenmontage und -umstecken, Reifendepot, Ölwechsel Service, KFZ Service,  Schnell Service, §57A Vorbereitung, KFZ Batterien, KFZ Lampen, KFZ Zubehör Kaffeautomat Shop für Getränke, Snacks, Süßigkeiten, Zigaretten
    ,
    "spritPrice": {
      "0": {
        "amount": 1.097,
        "datAnounce": Wed Nov 09 12:47:41 CET 2016,
        "datValid": 1478692061000,
        "errorCode": 0,
        "errorItems":
    },
        "spritId": SUP
    }
    },
    "strom": false,
    "technikA": false,
    "technikB": false,
    "technikC": false,
    "telephone": 4315872307,
    "url": http://www.spritinn.at
    }*/

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

