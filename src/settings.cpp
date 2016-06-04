#include "settings.h"

Settings::Settings(QObject *parent) :
    QObject(parent)
{
}
void Settings::setValue(QString path, QVariant value) { QSettings sttngs; sttngs.setValue( getname()+"/"+path, value ); }
QVariant Settings::getValue(QString path) { QSettings sttngs; return sttngs.value( getname()+"/"+path ); }
