import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "FR - Prix Carburants"
    description: "https://www.prix-carburants.gouv.fr/"
    units: { "currency":"€", "distance": "km" }
    countryCode: "fr"
    property string url: "http://harbour-spritradar-fork.w4f.eu/fr/"
    type: "e10"
    types: ["Gazole", "SP95", "E10", "E85", "GPLc", "SP98"]
    names: [qsTr("Gazole"), qsTr("SP95"), qsTr("E10"), qsTr("E85"), qsTr("GPLc"), qsTr("SP98")]

    settings: Settings {
        name: "PrixCarburants"

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
                useGps = JSON.parse( getValue( "gps" ) )
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
            setValue( "type", "GPR" )
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
        else getItemsByAddress(getItems)
    }

    function getItems( lat, lng ) {
        errorCode = 0
        itemsBusy = true
        items.clear()
        coverItems.clear()
        var req = new XMLHttpRequest()
        req.open( "GET", url+"?get=stations&lat="+lat+"&lng="+lng+"&radius="+searchRadius )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    var x = JSON.parse( req.responseText )
                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var price = { price:0 }
                        for( var j = 0; j < o.prices.length; j++ ) {
                            if( o.prices[j].id == type ) price = o.prices[j]
                        }
                        if( price.price == 0 ) continue
                        var itm = {
                            "stationID": o.id,
                            "stationName": o.adresse,
                            "stationPrice": price.price,
                            "stationAdress": o.adresse,
                            "stationDistance": o.distance*1000,
                            "customMessage": false
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
        stationBusy = true
        station = {}
        stationPage = pageStack.push( "../GasStation.qml", {stationId:id} )
        var req = new XMLHttpRequest()
        req.open( "GET", url+"?get=station&id="+id )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    var st = JSON.parse( req.responseText )
                    var price = []; var service = []
                    for( var j = 0; j < st.prices.length; j++ ) {
                        try {
                            price[price.length] = { "title":qsTr(names[types.indexOf(st.prices[j].id)]), "price":st.prices[j].price, "sz":Theme.fontSizeLarge, "tf":true }
                           } catch( ex ) {
                            console.log( JSON.stringify(st))
                        }
                    }
                    for( j = 0; j < st.services.length; j++ ) {
                        service[service.length] = { title:"",text:st.services[j] }
                    }
                    var optimes = st.openingtimes.length>0?[ {title:qsTr("Daily"), "text":st.openingtimes[0].from+"-"+st.openingtimes[0].to }, {title:qsTr("Except"), "text":st.openingtimes[0].except?st.openingtimes[0].except:"-" } ]: []
                    station = {
                        "stationID":st.id,
                        "stationName":st.adresse,
                        "stationAdress": {
                            "street": st.adresse,
                            "county":st.ville,
                            "country":"",//country,
                            "latitude":st.latitude,
                            "longitude":st.longitude
                        },
                        "content": [
                            { "title":qsTr("Opening times"), "items":optimes },
                            { "title":qsTr("Prices"), "items": price },
                            { "title":qsTr("Services"), "items": service },
                        ]
                    }
                }
                catch(e) {
                    console.log( e.message )
                    stationPage.station = {}
                    stationBusy = false
                }
                stationPage.station = station
                stationBusy = false
            }
        }
        req.send()
    }

    function getPriceForFav( id ) {
        var req = new XMLHttpRequest()
        req.open( "GET", url+"?get=station&id="+id )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    var o = JSON.parse( req.responseText )
                    var price = 0
                        for( var j = 0; j < o.prices.length; j++ ) {
                            if( o.prices[j].id == type ) price = o.prices[j].price
                        }
                    if( price == 0) return
                    setPriceForFav( id, price )
                }
                catch(e) {
console.log(e.message)
                }
            }
        }
        req.send()
    }

    radiusSlider {
        maximumValue: 25
    }

    content: Component {
        Column {}
    }
}

