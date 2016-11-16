import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.spritradar.Util 1.0

Plugin {
    id: page

    name: "IT - Osservaprezzi Carburanti"
    description: "Fonte: Ministero dello Sviluppo Economico"
    units: { "currency":"€", "distance": "km" }
    countryCode: "it"
    property string url: "http://harbour-spritradar.w4f.eu/it/"
    type: "Benzina"
    types: ["Benzina","Gasolio","Metano","GPL","((.*(benzina|benzin|petrol|spezial).+)|(.+(benzina|benzin|petrol|spezial).*))","(.+(gasolio|diesel|gasoline|spezial).*)|(.*(gasolio|diesel|gasoline|spezial).+)"]
    names: [qsTr("Benzina"),qsTr("Gasolio"),qsTr("Metano"),qsTr("GPL"),qsTr("Benzina Special"),qsTr("Gasolio Special")]


    settings: Settings {
        name: "sviluppoeconomico"

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
            setValue( "type", "Benzina" )
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
        else getItemsByAddress( "IT", getItems )
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
                    //console.log( req.responseText )
                    var x = eval( req.responseText )

                    for( var i = 0; i < x.length; i++ ) {
                        var o = x[i]
                        var price = { price:0 }
                        var sPrice = { price:0 }
                        for( var j = 0; j < o.prices.length; j++ ) {
                            if( o.prices[j].type.toLowerCase() == type.toLowerCase() && ( o.prices[j].price <= price.price || price.price == 0 ) ) { if( price.price != 0 ) { sPrice = price; } price = o.prices[j] }
                            else if( type.indexOf("spezial") > -1 && ( (new RegExp( type, "i" )).test(o.prices[j].type) && ( price.price > o.prices[j].price || price.price == 0 ) ) ) { if( price.price != 0 ) { sPrice = price; } price = o.prices[j] }
                        }
                        if( price.price == 0 ) continue
                        var itm = {
                            "stationID": o.id,
                            "stationName": (o.brand=="Pompe Bianche"?"":o.brand+" - ")+o.name,
                            "stationPrice": price.price,
                            "stationAdress": o.adress.replace("?", ", "),//capitalizeString(o.street) + (typeof(o.houseNumber) == "object" ? "" : " " + o.houseNumber) + ", " + o.postCode + " " + capitalizeString(o.place),
                            "stationDistance": o.distance,
                            "customMessage": price.self?"":qsTr("Serviced")
                        }
                        items.append( itm )
                        if( sPrice.price != 0 ) {
                            itm.stationPrice = sPrice.price
                            itm.customMessage = sPrice.self?"":qsTr("Serviced")
                            items.append( itm )
                        }
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
                        price[price.length] = { "title":st.prices[j].type+(st.prices[j].self?"":" ("+qsTr("Serviced")+")"), "price":st.prices[j].price, "sz":Theme.fontSizeLarge, "tf":true }
                    }
                    var adress = st.adress.split("?")
                    var street = adress[0].split( " " )
                    var zipcode = street[street.length-1]
                    street = street.splice(0, street.length-1).join(" ")
                    adress = adress[1].split(" ")
                    var provincia = adress[adress.length-1]
                    adress = adress.splice(0, adress.length-1).join(" ")
                    var county = zipcode+" "+adress
                    page.station = {
                        "stationID":st.id,
                        "stationName":(st.brand=="Pompe Bianche"?"":st.brand+" - ")+st.name,
                        "stationAdress": {
                            "street":capitalizeString(street),
                            "county":capitalizeString(county)+" "+provincia,
                            "country":"",//"Italy",
                            "latitude":st.lat,
                            "longitude":st.lng
                        },
                        "content": [
                            { "title":qsTr("Info"), items:[ {title:qsTr("Brand"), text:st.brand=="Pompe Bianche"?qsTr("Off-Brand"):st.brand},{title:qsTr("Updated"), text:toTimeSince(st.prices[0].date)} ] },
                            { "title":qsTr("Prices"), "items": price }

                        ]
                    }
                }
                catch ( e ) {
                    page.station = {}
                    stationBusy = false
                }
                stationPage.station = page.station
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
                    var o = eval( req.responseText )
                    var sPrice = {}
                    var price = {price:0}
                        for( var j = 0; j < o.prices.length; j++ ) {
                            if( o.prices[j].type.toLowerCase() == type.toLowerCase() && ( price.price > o.prices[j].price || price.price == 0 ) ) { if( price.price != 0 ) { sPrice = price; } price = o.prices[j] }
                            else if( type.indexOf("spezial") > -1 && ( (new RegExp( type, "i" )).test(o.prices[j].type) && ( price.price > o.prices[j].price || price.price == 0 ) ) ) { if( price.price != 0 ) { sPrice = price; } price = o.prices[j] }
                        }
                    if( price.price == 0) return
                    var y = favs.stations
                    for( var x in y ) {
                        if( y[x].id == id  ) y[x].price = price.price
                    }
                    favs.stations = y
                }
                catch ( e ) {
                }
            }
        }
        req.send()
    }

    function toTimeSince( t ) {
        return timeSince( Date.fromLocaleString( Qt.locale("it_IT"), t, "dd/MM/yyyy hh:mm:ss").getTime() )
    }

    radiusSlider {
        maximumValue: 25
    }

    content: Component {
        Column {}
    }
}

