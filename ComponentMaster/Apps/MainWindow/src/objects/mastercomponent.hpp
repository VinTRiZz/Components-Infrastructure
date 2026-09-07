#pragma once

#include <QObject>

#include "componentscommonconfiguration.hpp"

class MasterManifest;
class MasterSystem;

class MasterComponent : public QObject
{
    Q_OBJECT
public:
    explicit MasterComponent(const QString& compName, QObject *parent = nullptr);

    void setCommonConfig(ComponentsCommonConfiguration* pConfig);

    bool init();

    void setName(const QString& compName);
    QString getName() const;

    QString getRootPath() const;

private:
    ComponentsCommonConfiguration* m_pConfig {nullptr};

    QString m_name {};

    MasterSystem* m_pSystem {nullptr};

    void processNameChange();
};
