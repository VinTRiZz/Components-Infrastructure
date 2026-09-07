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

    return true;
}

bool MasterManifest::save()
{
    m_targetFile.reset();

    std::map<std::string, std::string> values;
        values["depends"] = m_depends.join(",").toStdString();
    m_targetFile.addSection("system", values);

    auto res = m_targetFile.write(m_targetFilePath.toStdString());
    if (!res) {
        COMPLOG_ERROR("MasterManifest: Failed to open target file \"",
                      m_targetFilePath.toStdString(),
                      "\" Reason:", m_targetFile.getLastErrorText());
    }
    return res;
}

QStringList MasterManifest::getDepends() const
{
    return m_depends;
}
