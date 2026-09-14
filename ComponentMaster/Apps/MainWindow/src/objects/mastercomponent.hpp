#pragma once

#include <QObject>

#include "componentscommonconfiguration.hpp"

#include <Components/ExtraClasses/Error.h>

class MasterSystem;
class MasterCMake;

class MasterComponent : public QObject
{
    Q_OBJECT
public:
    explicit MasterComponent(QObject *parent = nullptr);

    enum ErrorCode : int
    {
        ManifestError = ExtraClasses::UserCode + 1,
        CMakeError,
    };

    void setCommonConfig(ComponentsCommonConfiguration* pConfig);

    // For old arhitecture ones
    bool migrateComponent();

    // Used to work with components subdirs
    bool setupComponent();
    bool readComponent();
    void deleteComponent();

    bool setName(const QString& compName);
    QString getName() const;

    QString getRootPath() const;

private:
    ComponentsCommonConfiguration* m_pConfig {nullptr};

    QString m_name {};

    MasterSystem* m_pSystem {nullptr};
    MasterCMake* m_pCMake {nullptr};

    void processNameChange();
};
