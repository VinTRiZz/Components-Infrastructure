#include "constantdefinitions.hpp"

#include <QSysInfo>

#include <Components/Logger/Logger.h>

namespace ConstantDefinitions
{

QString createComponentUrl(const QString &componentName, bool isSsh)
{
    if (isSsh) {
        return QString("git@github.com:VinTRiZz/Components-%1.git").arg(componentName);
    }
    return QString("https://github.com/VinTRiZz/Components-%1.git").arg(componentName);
}

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
    if ("CMake" == packetName) {
        return "cmake";
    }

    if ("GCC" == packetName) {
        return "g++";
    }

    if ("Qt5" == packetName) {
        return "qtbase5-dev";
    }

    if ("Nlohmann/JSON" == packetName) {
        return "nlohmann-json3-dev";
    }

    if ("Boost_program_options" == packetName) {
        return "libboost-program-options-dev";
    }

    // Most of libs seem to be in "all" package // TODO: Work with lib names??
    if (packetName.startsWith("Boost")) {
        return "libboost-all-dev";
    }

    COMPLOG_WARNING("Unknown install packet name:", packetName.toStdString());
    return {};
}

QString DependencyEqus::fromPacket(const QString &packetName) const
{
    if (packetName.startsWith("Components")) {
        return packetName.right(strlen("Components-"));
    }

    if ("Qt5-Core" == packetName) {
        return "Qt5::Core";
    }

    if ("Nlohmann/JSON" == packetName) {
        return "nlohmann";
    }

    if ("SSL" == packetName) {
        return "ssl";
    }

    if ("C++ Crypto library" == packetName) {
        return "crypto";
    }

    if ("C++ Sodium crypto library" == packetName) {
        return "sodium";
    }

    COMPLOG_WARNING("Unknown dependency packet name:", packetName.toStdString());
    return {};
}

}
