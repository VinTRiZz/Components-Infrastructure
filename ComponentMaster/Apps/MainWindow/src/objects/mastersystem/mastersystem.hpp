#pragma once

#include <QObject>

class MasterManifest;

class MasterSystem : public QObject
{
    Q_OBJECT
public:
    explicit MasterSystem(QObject *parent = nullptr);

    void setDir(const QString& sysDir);

    bool init();

private:
    QString m_dir;

    MasterManifest* m_pManifest {nullptr};
};
