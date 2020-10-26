import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "ES - GeoportalGasolineras.es"
    description: "Ministerio de Industria, Energía y Turismo"
    units: { "currency":"€", "distance": "km" }
    countryCode: "es"
    property string url:  "https://geoportalgasolineras.es/rest/busquedaEstacionesInfo"
    type: "1"
    //types: ['GPR', 'G98', 'GOA', 'NGO', 'GOB', 'GOC', 'BIO', 'G95', 'BIE', 'GLP', 'GNC']
    //names: [qsTr('Gasolina 95 (G.Protecctión)'), qsTr('Gasolina 98'), qsTr('Gasóleo A habitual'), qsTr('Nuevo gasóleo'), qsTr('Gasóleo B'), qsTr('Gasóleo C'), qsTr('Biodiésel'), qsTr('Gasolina 95'), qsTr('Bioetanol'), qsTr('(GLP) - Gases licuados del petróleo'), qsTr('(GNC) - Gases natural comprimido')]
    types: ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
    names: ["Gasolina 95 E5","Gasolina 95 E10","Gasolina 95 E5 Premium","Gasolina 98 E5","Gasolina 98 E10","Gasóleo A habitual","Gasóleo Premium","Gasóleo B","Gasóleo C","Bioetanol","Biodiésel","Gases licuados del petróleo","Gas natural comprimido","Gas natural licuado","Hidrógeno"]

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
            setValue( "type", "1" )
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
        req.open( "POST", url )
        req.setRequestHeader("Accept", "application/json" )
        req.setRequestHeader("Content-Type", "application/json" )
        var off = searchRadius/111.2
        lat*=1; lng*=1; off*=1
        var x0=lng-off, y0=lat-off, x1=lng+off, y1=lat+off
        var payload =
            { "tipoEstacion" : "EESS"
            , "idProducto" : type*1
            , "x0" : x0
            , "y0" : y0
            , "x1" : x1
            , "y1" : y1
            }
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    console.log(req.status)
                    var x = JSON.parse( req.responseText )
                    if( x.errors ) {
                        itemsBusy = false
                        errorCode = 1
                        return
                    }
                    var stations = x.estaciones
                    for( var i = 0; i < stations.length; i++ ) {
                        var o = stations[i]
                        if( !o ) continue
                        var e = o.estacion 
                        var itm = 
                            { "stationID": e.coordenadaX_dec + ";" + e.coordenadaY_dec 
                            , "stationName": e.rotulo
                            , "stationPrice": o.precio
                            , "stationAdress": e.direccion
                            , "stationDistance": getGeoDistance( lat, lng, e.coordenadaY_dec, e.coordenadaX_dec )
                            , "customMessage": e.horario
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
        req.send(JSON.stringify(payload))
    }

    function requestStation( id ) {
        var lat = id.split(";")[1]
        var lng = id.split(";")[0]
        console.log( id, lat, lng )
        var req = new XMLHttpRequest()
        req.open( "POST", url )
        req.setRequestHeader("Accept", "application/json" )
        req.setRequestHeader("Content-Type", "application/json" )
        var off = 1/1112
        lat*=1; lng*=1; off*=1
        var x0=lng-off, y0=lat-off, x1=lng+off, y1=lat+off
        var payload =
            { "tipoEstacion" : "EESS"
            , "idProducto" : type*1
            , "x0" : x0
            , "y0" : y0
            , "x1" : x1
            , "y1" : y1
            }
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    console.log( req.status )
                    var x = JSON.parse( req.responseText )
                    var stations = x.estaciones
                    for( var i = 0; i < stations.length; i++ ) {
                        var o = stations[i]
                        if( !o ) continue
                        var e = o.estacion
                        if( e.coordenadaX_dec != lng || lat != e.coordenadaY_dec ) continue
                        var price =
                            [   { "title" : qsTr(names[types.indexOf(type)])
                                , "price" : o.precio
                                , "sz" : Theme.fontSizeLarge
                                , "tf" : true
                                }
                            ]
                        page.station =
                            { "stationID" : id
                            , "stationName" : e.rotulo
                            , "stationAdress":
                                { "street" : e.direccion
                                , "county" : e.codPostal + ", " + e.provincia
                                , "latitude" : e.coordenadaY_dec
                                , "longitude" : e.coordenadaX_dec
                                }
                            , "content" :
                                [ { "title":qsTr("Info"),   "items":[ {title:qsTr("Opening Times"), "text": e.horario } ] },
                                , { "title":qsTr("Prices"), "items": price }
                                ]
                            }
                        stationBusy = false
                        break
                    }
                }
                catch(e) {
                    console.log(e.message)
                    page.station = {}
                    stationBusy = false
                }
                stationPage.station = page.station
                stationBusy = false
            }
        }
        stationBusy = true
        station = {}
        stationPage = pageStack.push( "../GasStation.qml", {stationId:id} )
        req.send(JSON.stringify(payload))
    }

    function getPriceForFav( id ) {
        var lat = id.split(";")[1]
        var lng = id.split(";")[0]
        var req = new XMLHttpRequest()
        req.open( "POST", url )
        req.setRequestHeader("Accept", "application/json" )
        req.setRequestHeader("Content-Type", "application/json" )
        var off = 1/1112
        lat*=1; lng*=1; off*=1
        var x0=lng-off, y0=lat-off, x1=lng+off, y1=lat+off
        var payload =
            { "tipoEstacion" : "EESS" , "idProducto" : type*1
            , "x0" : x0
            , "y0" : y0
            , "x1" : x1
            , "y1" : y1
            }
        req.onreadystatechange = function() {
            if( req.readyState == 4 ) {
                try {
                    var x = JSON.parse( req.responseText )
                    var stations = x.estaciones
                    for( var i = 0; i < stations.length; i++ ) {
                        var o = stations[i]
                        if( !o ) continue
                        if( o.estacion.coordenadaX_dec != lng || lat != o.estacion.coordenadaY_dec ) continue
                        setPriceForFav( id, o.precio )
                        return
                    }
                }
                catch(e) {
                    console.log(e.message)
                }
            }
        }
        req.send(JSON.stringify(payload))
    }

    radiusSlider {
        maximumValue: 25
    }

    content: Component {
        Column {}
    }
}

