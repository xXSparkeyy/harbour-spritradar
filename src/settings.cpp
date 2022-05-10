#include "settings.h"
#include <QtQml>
#include <QtQml/QQmlContext>

Settings::Settings( QObject *parent):
    QObject(parent)
{
}

Settings::~Settings()
{
}


void Settings::setValue(QString path, QVariant value) { QSettings sttngs; sttngs.setValue( getname()+"/"+path, value ); }
QVariant Settings::getValue(QString path) { QSettings sttngs; return sttngs.value( getname()+"/"+path ); }
