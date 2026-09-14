#include "constantdefinitions.hpp"

#include <QSysInfo>

#include <Components/Logger/Logger.h>

namespace ConstantDefinitions
{

InstallEqus::InstallEqus()
{
    m_operationSystem = QSysInfo::prettyProductName();
}

QString InstallEqus::getInstallationCandidate(const QString &packetName) const
{
    if ("Debian GNU/Linux 12 (bookworm)" == m_operationSystem) {
        return getDebianCandidate(packetName);
    }

    COMPLOG_WARNING("Unknown operation system:", m_operationSystem.toStdString());
    return {};
}

QString InstallEqus::getDebianCandidate(const QString &packetName) const
{
    COMPLOG_WARNING("Unknown install packet name:", packetName.toStdString());
    return {};
}

}
