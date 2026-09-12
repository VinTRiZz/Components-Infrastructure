#pragma once

#include <QObject>

class MasterCMake : public QObject
{
    Q_OBJECT
public:
    explicit MasterCMake(QObject *parent = nullptr);

    QStringList getSwitchList() const;

    void setSwitchEnabled(const QString& switchName, bool isEn);
    bool getIsSwitchEnabled(const QString& switchName) const;

signals:
};


