#include "svmanager.h"

SVManager::SVManager(QObject *parent) : QObject(parent)
{
    stationUrl = "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv";
    pricesUrl = "http://www.sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv";

}

QList<QString> SVManager::download( QString url ) {
    // create custom temporary event loop on stack
    QEventLoop eventLoop;
    QNetworkAccessManager mgr;
    QNetworkDiskCache *diskCache = new QNetworkDiskCache(this);
    diskCache->setCacheDirectory("/home/nemo/.config/harbour-spritradar/cache");
    mgr.setCache(diskCache);
    QDateTime lastmod =  diskCache->metaData( stationUrl ).lastModified();
    QDateTime lastref = QDateTime( QDateTime::currentDateTime().date() ).addSecs( 28800 );
    if( QDateTime::currentDateTime()<lastref) lastref.addDays(-1);
    qDebug() << "Cache is From:" << lastmod  << "Should be from:" <<lastref;
    if( lastmod < lastref ) { qDebug()<< "Dropping Cache";diskCache->clear(); }
    // "quit()" the event-loop, when the network request "finished()"
    QObject::connect(&mgr, SIGNAL(finished(QNetworkReply*)), &eventLoop, SLOT(quit()));
    // the HTTP request
    QUrl _url = QUrl( url );
    QNetworkRequest req( _url );
    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    qDebug() << _url;
    QNetworkReply *reply = mgr.get(req);
    eventLoop.exec(); // blocks stack until "finished()" has been called

    QList<QString> ret;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray l;
        int i = 0;
        while( ( l = reply->readLine() ) != QByteArray() ) {
            if( i > 1 ) ret.append( QString( l.split('\n').at(0) ) );
            i++;
        }
        delete reply;

    }
    else {
        //failure
        qDebug() << "Failure" <<reply->errorString();
        delete reply;
    }
    return ret;
}
void SVManager::loadStations() {
    int missingCoords = 0;
    stations.clear();
    QList<QString> stns = download( stationUrl );
    for( int i = 0; i < stns.count(); i++ ) {
        QStringList a = stns.at(i).split( ";" );
        SVStation station( a[0], a[4], a[5]+"?"+a[6]+" ("+a[7]+")", a[2], a[8], a[9] );
        if( a[8] == "" ) missingCoords++;
        stations.append( station );
    }
    qDebug() << stations.count() << "Stations loaded";
    qDebug() << qCeil(missingCoords/stations.count()*100) << missingCoords;
}
void SVManager::loadPrices() {
    prices.clear();
    QList<QString> prcs = download( pricesUrl );
    for( int i = 0; i < prcs.count(); i++ ) {
        QStringList a = prcs.at(i).split( ";" );
        SVPrice price( a[0], a[1], a[2], a[3]=="0"?false:true, a[4] );
        prices.append( price );
    }
    qDebug() << prices.count() << "Prices loaded";
}
void SVManager::prepare() {
    loadStations();
    loadPrices();
}

QList<SVPrice> SVManager::getPrices( QString id ) {
    QList<SVPrice> ret;
    for( int i = 0; i<prices.count(); i++ ) {
        SVPrice p( prices.at(i) );
        if( id == p.id ) {
            ret.append( p );
        }
    }
    return ret;
}

int SVManager::getDistance(float lat1, float lon1, float lat2, float lon2 ) {
    return QGeoCoordinate( lat1, lon1 ).distanceTo( QGeoCoordinate( lat2, lon2 ) );
}
float SVManager::r( float d ) {
    return qDegreesToRadians( d );
}

void SVManager::getStation( QString id) {
    QtConcurrent::run(this, &SVManager::getItem, id);
}
void SVManager::getItem( QString id ) {
    SVStation ret;
    for( int i = 0; i<stations.count(); i++ ) {
        SVStation s( stations.at(i) );
        if( s.id == id ) {
            s.prices = toJSON(getPrices( s.id ));
            emit gotStation( toJSON(s) );
            return;
        }
    }
}

void SVManager::getStations() {
    QtConcurrent::run(this, &SVManager::getItems);
}
void SVManager::getItems() {
    QList<SVStation> ret;
    for( int i = 0; i<stations.count() && ret.count()<100; i++ ) {
        SVStation s = stations.at(i);
        if( s.lat != "" ) {
            s.distance = getDistance( s.lat.toFloat(), s.lng.toFloat(), plat, plng );
            if( s.distance < pradius ) {
                s.prices = toJSON(getPrices( s.id ));
                ret.append( s );
            }
        }
    }
    emit gotStations( toJSON(ret) );
}

QString SVManager::toJSON( QList<SVStation> s ) {
    QString ret = "[";
    int i;
    for( i = 0; i<s.count()-1; i++ ) {
        ret += toJSON( s.at(i) )+", ";
    }
    if( i < s.count() ) {
        ret += toJSON( s.at(i) );
    }
    return ret+"]";
}
QString SVManager::toJSON( QList<SVPrice> s ) {
    QString ret = "[";
    int i;
    for( i = 0; i<s.count()-1; i++ ) {
        ret += toJSON( s.at(i) )+", ";
    }
    if( i < s.count() ) {
        ret += toJSON( s.at(i) );
    }
    return ret+"]";
}
QString SVManager::toJSON( SVStation s ) {
    return "{ \"name\": \""+x(s.name)+"\", \"id\":\""+s.id+"\", \"adress\": \""+x(s.adress)+"\", \"brand\": \""+x(s.brand)+"\", \"lat\": \""+x(s.lat)+"\", \"lng\": \""+x(s.lng)+"\", \"prices\": "+s.prices+", \"distance\":\""+QString::number(qCeil(s.distance))+"\" }";
}
QString SVManager::toJSON( SVPrice s ) {
    return "{ \"type\": \""+x(s.name)+"\", \"price\": \""+x(s.price)+"\", \"date\": \""+x(s.date)+"\", \"self\": "+(s.self?"true":"false")+"}";
}
QString SVManager::x( QString p ) {
    p.replace( QRegularExpression("\""), "\\\"" );
    return p;
}
