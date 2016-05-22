#include "svprice.h"

SVPrice::SVPrice()
{
}
SVPrice::SVPrice( const SVPrice &s)
{
    id = s.id;
    name = s.name;
    price = s.price;
    self = s.self;
    date = s.date;
}

SVPrice::SVPrice( QString i, QString n, QString p, bool sf, QString dt )
{
    id = i;
    name = n;
    price = p;
    self = sf;
    date = dt;
}
