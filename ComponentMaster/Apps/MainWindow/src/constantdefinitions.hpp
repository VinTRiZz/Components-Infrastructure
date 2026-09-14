#pragma once

#include <QString>

#include <unordered_map>

namespace ConstantDefinitions
{

// Used to work with GitHub
QString createComponentUrl(const QString& componentName, bool isSsh = false);

class InstallEqus
{
public:
    InstallEqus();

    // Used to work with different OS
    QString getInstallationCandidate(const QString& packetName) const;

private:
    QString m_operationSystem;

    QString getDebianCandidate(const QString& packetName) const;
};


class DependencyEqus
{
public:
    QString fromPacket(const QString& packetName) const;

private:

};

}
