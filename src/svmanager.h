#ifndef SVMANAGER_H
#define SVMANAGER_H

#include <QObject>
#include "svstation.h"
#include "svprice.h"
#include <QDebug>
#include <QRegularExpression>
#include <QThread>
#include <QtConcurrent>
#include <QGeoCoordinate>
#include <QNetworkDiskCache>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>
#include <QUrl>
#include <QtMath>

class SVManager : public QObject
{
    Q_OBJECT
public:

    explicit SVManager(QObject *parent = 0);
    QList<QString> download( QString url );

    Q_PROPERTY(float lat READ lat WRITE setlat)
    Q_PROPERTY(float lng READ lng WRITE setlng)
    Q_PROPERTY(int radius READ radius WRITE setradius)

    Q_INVOKABLE void getStations();
    Q_INVOKABLE void getStation( QString id );

    QString toJSON( QList<SVStation> );
    QString toJSON( QList<SVPrice> );
    QString toJSON( SVStation );
    QString toJSON( SVPrice );
    QString x( QString );

    int getDistance( float lat1, float lng1, float lat2, float lng2 );
    float r( float d );
    void loadStations();
    void loadPrices();
    void appendPrices();
    QList<SVPrice>  getPrices( QString );
    Q_INVOKABLE void prepare();
    QList<SVStation> stations;
    QList<SVPrice> prices;

    float lat() { return plat; }
    float lng() { return plng; }
    int radius() { return pradius; }

    void setlat( float l ) { plat = l; }
    void setlng( float l ) { plng = l; }
    void setradius( int l ) { pradius = l; }

    void getItems();
    void getItem( QString );
signals:
    void gotStations( QString stations );
    void gotStation( QString station );
public slots:

private:
    float plat; float plng; int pradius;
    QString stationUrl;
    QString pricesUrl;
};

#endif // SVMANAGER_H
