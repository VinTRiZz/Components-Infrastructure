#include "mastercomponent.hpp"

#include <QDir>

#include <Components/Logger/Logger.h>

#include "mastersystem/mastersystem.hpp"

MasterComponent::MasterComponent(const QString& compName, QObject *parent) :
    QObject{parent}
{
    setName(m_name);

    m_pSystem = new MasterSystem(this);
}

void MasterComponent::setCommonConfig(ComponentsCommonConfiguration* pConfig)
{
    m_pConfig = pConfig;

    // TODO: Process signals
}

bool MasterComponent::init()
{
    return false;
}

void MasterComponent::setName(const QString &compName)
{
    if (compName.contains(QDir::separator())) {
        COMPLOG_ERROR("MasterComponent: Invalid component name (ignored):", m_name.toStdString());
        return;
    }
    m_name = compName;

    processNameChange();
}

QString MasterComponent::getName() const
{
    return m_name;
}

QString MasterComponent::getRootPath() const
{
    if (m_pConfig) {
        return m_pConfig->getRootDir() + QDir::separator() + m_name;
    }
    return m_name;
}

void MasterComponent::processNameChange()
{
    m_pSystem->setDir(getRootPath());
}