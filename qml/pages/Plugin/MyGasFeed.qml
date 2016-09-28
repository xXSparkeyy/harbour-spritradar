import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "US - MyGasFeed"
    description: "Seems quite dead :("
    units: { "currency":"$", "distance": "mi" }
    countryCode: "us"
    type: "e10"
    types: ["reg","mid","pre","diesel"]
    names: [qsTr("Regular"),qsTr("Mid-Grade"),qsTr("Premium"),qsTr("Diesel")]

    property string url: "http://api.mygasfeed.com"

    settings: Settings {
        name: "mygasfeed"

        function save() {
            setValue( "radius", searchRadius )
            setValue( "type", type )
            setValue( "sort", main.sort )
            setValue( "gps", useGps )
            setValue( "address", address )
        }
        function load() {
           try {
                searchRadius = getValue( "radius" )
                type = getValue( "type" )
                main.sort = getValue( "sort" )
                useGps = eval( getValue( "gps" ) )
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
            setValue( "type", "e5" )
            setValue( "sort", main.sort )
            setValue( "gps", false )
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
        else getItemsByAddress("us", getItems)
    }

    function getItems( lat, lng ) {
        var req = new XMLHttpRequest()
        req.open( "GET", url+ "/stations/radius/"+lat+"/"+lng+"/"+radiusSlider.value+"/"+type+"/price/ihnv7692u1.json" )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    //console.log(req.responseText)
                    var x = eval( req.responseText ).stations
                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var price = o[type+"_price"]
                        if( price == "N/A" ) continue
                        var itm = {
                            "stationID": o.id,
                            "stationName": o.station,
                            "stationPrice": price,
                            "stationAdress": o.address+" "+o.city+" ("+o.region+")",
                            "stationDistance": o.distance.split("m")[0],
                            "customMessage": o[type+"_date"]
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
        req.open( "GET", url+"/stations/details/"+id+"/ihnv7692u1.json" )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                //console.log( req.responseText )
                try {
                    var x = eval( req.responseText )
                    x = x.details
                    var price = []
                    var times = []
                    if( x.reg_price != "N/A" ) { price.push( { "title":"Regular",       "price":x.reg_price, "sz":Theme.fontSizeLarge } ); times.push( { "title":"Regular",       "text":x.reg_date } ) }
                    if( x.mid_price != "N/A" ) { price.push( { "title":"Mid-Range", "price": x.mid_price, "sz":Theme.fontSizeLarge } ); times.push( { "title":"Mid-Range", "text": x.mid_date } ) }
                    if( x.pre_price != "N/A" ) { price.push( { "title":"Premium", "price": x.pre_price, "sz":Theme.fontSizeLarge } ); times.push( { "title":"Premium", "text": x.pre_date } ) }
                    if( x.diesel_price != "N/A" && x.diesel == 1 ) { price.push({ "title":"Diesel", "price": x.diesel_price, "sz":Theme.fontSizeLarge }); times.push({ "title":"Diesel", "text": x.diesel_date }) }



                    station = {
                        "stationID":x.id,
                        "stationName":x.station,
                        "stationAdress": {
                            "street":x.address,
                            "county":x.region,
                            "country":"",
                            "latitude":x.lat,
                            "longitude":x.lng
                        },
                        "content": [
                            { "title":qsTr("Prices"), "items": price },
                            { "title":qsTr("Updated"), "items": times }
                        ]
                    }
                    stationBusy = false
                }
                catch ( e ) {
                    station = {}
                    stationBusy = false
                }
                //log( station)
                stationPage.station = station
            }
        }
        req.send()
    }

    radiusSlider {
        maximumValue: 20
    }

    content: Component {
        Column {}
    }
}

