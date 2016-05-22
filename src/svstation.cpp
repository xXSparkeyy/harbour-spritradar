#include "svstation.h"

SVStation::SVStation()
{
}

SVStation::SVStation( const SVStation &s )
{
    id = s.id;
    name = s.name;
    adress = s.adress;
    lat = s.lat;
    lng = s.lng;
    prices = s.prices;
    distance = s.distance;
    brand = s.brand;
}
SVStation::SVStation(QString sid, QString sname, QString sadress, QString brd, QString slat, QString slng )
{
    id = sid;
    name = sname;
    adress = sadress;
    lat = slat;
    lng = slng;
    prices = "[]";
    distance = 0;
    brand = brd;
}

