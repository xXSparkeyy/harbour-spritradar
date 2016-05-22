#ifndef SVSTATION
#define SVSTATION
#include "svprice.h"

class SVStation
{
public:
    SVStation();
    SVStation( const SVStation &s );
    SVStation(QString sid, QString sname, QString sadress, QString brand, QString lat, QString lng);
    QString name;
    QString id;
    QString adress;
    QString brand;
    QString lat;
    QString lng;
    int distance;
    QString prices;
signals:

public slots:
};


#endif // SVSTATION

