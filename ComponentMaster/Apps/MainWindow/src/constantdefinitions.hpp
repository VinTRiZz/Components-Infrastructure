#pragma once

#include <QString>

#include <unordered_map>

namespace ConstantDefinitions
{

class InstallEqus
{
public:
    InstallEqus();

    QString getInstallationCandidate(const QString& packetName) const;

private:
    QString m_operationSystem;

    QString getDebianCandidate(const QString& packetName) const;
};

}
