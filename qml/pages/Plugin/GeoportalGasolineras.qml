import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "ES - GeoportalGasolineras.es"
    description: "Ministerio de Industria, Energía y Turismo"
    units: { "currency":"€", "distance": "km" }
    countryCode: "es"
    property string url: "http://harbour-spritradar.w4f.eu/es/"
    type: "GPR"
    types: ['GPR', 'G98', 'GOA', 'NGO', 'GOB', 'GOC', 'BIO', 'G95', 'BIE', 'GLP', 'GNC']
    names: [qsTr('Gasolina 95 (G.Protecctión)'), qsTr('Gasolina 98'), qsTr('Gasóleo A habitual'), qsTr('Nuevo gasóleo'), qsTr('Gasóleo B'), qsTr('Gasóleo C'), qsTr('Biodiésel'), qsTr('Gasolina 95'), qsTr('Bioetanol'), qsTr('(GLP) - Gases licuados del petróleo'), qsTr('(GNC) - Gases natural comprimido')]


    settings: Settings {
        name: "GeoportalGasolineras"

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
        else getItemsByAddress("ES", getItems)
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
                //console.log(req.responseText)
                    var x = eval( req.responseText )
                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var price = { price:0 }
                        for( var j = 0; j < o.prices.length; j++ ) {
                            if( o.prices[j].type == type ) price = o.prices[j]
                        }
                        if( price.price == 0 ) continue
                        var itm = {
                            "stationID": o.id,
                            "stationName": o.name,
                            "stationPrice": price.price,
                            "stationAdress": o.address,
                            "stationDistance": o.distance,
                            "customMessage": o.open
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
        req.open( "GET", url+"?get=station&id="+id )
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    var st = eval( req.responseText )
                    var price = []
                    for( var j = 0; j < st.prices.length; j++ ) {
                        price[price.length] = { "title":qsTr(names[types.indexOf(st.prices[j].type)]), "price":st.prices[j].price, "sz":Theme.fontSizeLarge, "tf":true }
                    }
                    var addr = st.address.split( ", " )
                    var o = 0
                    var street = addr[0]+(parseInt(addr[1])!="NaN"?" "+addr[1]:"")
                    if(addr[1]!="NaN") o = 1
                    var county = addr[1+o]+(3+o==addr.length?"":", "+addr[2+o])
                    var country = addr[addr.length-1]
                    page.station = {
                        "stationID":st.id,
                        "stationName":st.name,
                        "stationAdress": {
                            "street": street,
                            "county":county,
                            "country":"",//country,
                            "latitude":st.lat,
                            "longitude":st.lng
                        },
                        "content": [,
                            { "title":qsTr("Info"),   "items":[ {title:qsTr("Opening Times"), "text":st.open } ] },
                            { "title":qsTr("Prices"), "items": price }
                        ]
                    }
                    stationBusy = false
                }
                catch ( e ) {
                    page.station = {}
                    stationBusy = false
                }
                stationPage.station = page.station
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
                    var o = eval( req.responseText )
                    var price = 0
                        for( var j = 0; j < o.prices.length; j++ ) {
                            if( o.prices[j].type == type ) price = o.prices[j].price
                        }
                    if( price == 0) return
                    var y = favs.stations
                    for( var x in y ) {
                        if( y[x].id == id  ) y[x].price = price
                    }
                    favs.stations = y
                }
                catch ( e ) {
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

