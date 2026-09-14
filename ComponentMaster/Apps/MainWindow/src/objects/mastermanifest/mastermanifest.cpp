#include "mastermanifest.hpp"

#include <Components/Logger/Logger.h>

#include <QDir>
#include <QFileInfo>

MasterManifest::MasterManifest(QObject *parent)
    : QObject{parent}
{

}

bool MasterManifest::setTargetFile(const QString &filePath)
{
    auto targetFileInfo = QFileInfo(filePath);
    auto targetFileDir = targetFileInfo.dir();
    if (!targetFileDir.exists() ||
        !targetFileDir.isReadable() ||
        targetFileInfo.isFile()) {
        COMPLOG_ERROR("MasterManifest: Invalid target file \"", filePath.toStdString(), "\"");
        return false;
    }
    m_targetFilePath = filePath;
    return true;
}

QString MasterManifest::getTargetFile() const
{
    return m_targetFilePath;
}

bool MasterManifest::init()
{
    m_depends.clear();

    if (!m_targetFile.read(m_targetFilePath.toStdString())) {
        COMPLOG_ERROR("MasterManifest: Failed to open target file \"",
                      m_targetFilePath.toStdString(),
                      "\" Reason:", m_targetFile.getLastErrorText());
        return false;
    }

    auto settings = m_targetFile.getSection("system");

    auto deps = QString::fromStdString(settings["depends"]);
    m_depends = deps.split(",", Qt::SkipEmptyParts);
    initDefaultDepends();

    auto cmakeSwitches = QString::fromStdString(settings["cmake-switches"]);
    m_cmakeSwitches = deps.split(",", Qt::SkipEmptyParts);
    initDefaultSwitches();

    m_version = QString::fromStdString(settings["version"]);

    return true;
}

bool MasterManifest::save()
{
    m_targetFile.reset();
    initDefaultDepends();
    initDefaultSwitches();

    std::map<std::string, std::string> values;
        values["depends"] = m_depends.join(",").toStdString();
        values["cmake-switches"] = m_cmakeSwitches.join(",").toStdString();
    m_targetFile.addSection("system", values);

    auto res = m_targetFile.write(m_targetFilePath.toStdString());
    if (!res) {
        COMPLOG_ERROR("MasterManifest: Failed to open target file \"",
                      m_targetFilePath.toStdString(),
                      "\" Reason:", m_targetFile.getLastErrorText());
    }
    return res;
}

QString MasterManifest::getVersion() const
{
    return m_version;
}

void MasterManifest::addSwitch(const QString &cmakeSwitch)
{
    if (!m_cmakeSwitches.contains(cmakeSwitch)) {
        m_cmakeSwitches.push_back(cmakeSwitch);
    }
}

void MasterManifest::removeSwitch(const QString &cmakeSwitch)
{
    m_cmakeSwitches.removeOne(cmakeSwitch);
}

QStringList MasterManifest::getCMakeSwitches() const
{
    return m_cmakeSwitches;
}

void MasterManifest::addDepend(const QString &dep)
{
    if (!m_depends.contains(dep)) {
        m_depends.push_back(dep);
    }
}

void MasterManifest::removeDepend(const QString &dep)
{
    m_depends.removeOne(dep);
}

QStringList MasterManifest::getDepends() const
{
    return m_depends;
}

void MasterManifest::initDefaultSwitches()
{
    if (!m_cmakeSwitches.contains("tests_enabled")) {
        m_cmakeSwitches.push_back("tests_enabled");
    }

    if (!m_cmakeSwitches.contains("qt_enabled")) {
        m_cmakeSwitches.push_back("qt_enabled");
    }
}

void MasterManifest::initDefaultDepends()
{
    if (!m_cmakeSwitches.contains("Components-Core")) {
        m_cmakeSwitches.push_back("Components-Core");
    }
}
