#ifndef SVPRICE_H
#define SVPRICE_H

#include <QObject>

class SVPrice
{
public:
    SVPrice();
    SVPrice( const SVPrice &p );
    SVPrice(QString id, QString n, QString p, bool , QString dt);
    QString name;
    QString price;
    QString id;
    QString date;
    bool self;
signals:

public slots:
};

#endif // SVPRICE_H
