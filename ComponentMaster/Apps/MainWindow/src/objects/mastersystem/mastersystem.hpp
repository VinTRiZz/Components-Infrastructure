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
    bool migrate();

    MasterManifest* getManifest() const;

private:
    QString m_dir;

    MasterManifest* m_pManifest {nullptr};
};
