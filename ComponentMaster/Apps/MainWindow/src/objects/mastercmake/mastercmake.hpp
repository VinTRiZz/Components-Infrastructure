#pragma once

#include <QObject>

class MasterCMake : public QObject
{
    Q_OBJECT
public:
    explicit MasterCMake(QObject *parent = nullptr);

signals:
};
