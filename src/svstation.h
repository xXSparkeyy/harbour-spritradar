#ifndef SVSTATION_H
#define SVSTATION_H

#include <QObject>

class SVStation : public QObject
{
    Q_OBJECT
public:
    explicit SVStation(QObject *parent = 0);

signals:

public slots:
};

#endif // SVSTATION_H
