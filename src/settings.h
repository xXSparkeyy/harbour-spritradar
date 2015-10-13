#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject *parent = 0);
    Q_INVOKABLE void setValue( QString path, QVariant value );
    Q_INVOKABLE QVariant getValue( QString path );
signals:

public slots:
private:
    QString settingsPath;
};

#endif // SETTINGS_H
