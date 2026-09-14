#pragma once

#include <QObject>
#include <QVariant>

#include "cmakeswitch.hpp"
#include "../mastermanifest/mastermanifest.hpp"

class MasterCMake : public QObject
{
    Q_OBJECT
public:
    explicit MasterCMake(QObject *parent = nullptr);

    void setManifest(MasterManifest* pManifest);

    void setTargetFile(const QString& targetFile);
    void setName(const QString& name);

    bool readTarget();
    bool writeChanges() const;

    void setSwitchList(const QStringList& switchList);
    std::vector<std::shared_ptr<CMakeSwitch> > getSwitchList() const;

private:
    QString m_targetFile;
    QString m_componentName;
    std::vector<std::shared_ptr<CMakeSwitch> > m_switches;

    MasterManifest* m_pManifest {nullptr};

    QByteArray generateCMakeText() const;
};


