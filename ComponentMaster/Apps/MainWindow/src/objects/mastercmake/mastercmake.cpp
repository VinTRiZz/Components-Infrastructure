#include "mastercmake.hpp"

#include "constantdefinitions.hpp"

MasterCMake::MasterCMake(QObject *parent)
    : QObject{parent}
{

}

void MasterCMake::setManifest(MasterManifest *pManifest)
{
    m_pManifest = pManifest;
}

void MasterCMake::setTargetFile(const QString &targetFile)
{
    m_targetFile = targetFile;
}

void MasterCMake::setName(const QString &name)
{
    m_componentName = name;
}

bool MasterCMake::readTarget()
{
    // TODO: Read depends from prev version and add into manifest
    return true;
}

bool MasterCMake::writeChanges() const
{
    auto txt = generateCMakeText();
    COMPLOG_DEBUG("CMAKE TEXT:\n", txt.toStdString());
    return false;
}

void MasterCMake::setSwitchList(const QStringList &switchList)
{
    m_switches.clear();
    for (auto& swName : switchList) {
        auto pSw = std::make_shared<CMakeSwitch>();
        pSw->setName(swName);
        m_switches.push_back(pSw);
    }
}

std::vector<std::shared_ptr<CMakeSwitch> > MasterCMake::getSwitchList() const
{
    return m_switches;
}

QByteArray MasterCMake::generateCMakeText() const
{
    QByteArray res;

    if (!m_pManifest) {
        COMPLOG_WARNING("Manifest not set, CMake text could not be generated");
        return res;
    }

    // Get dependencies
    auto deps = m_pManifest->getDepends();

    // Remove components from dependencies
    decltype(deps) depsComponents;
    auto depsComponentsBegin = std::stable_partition(deps.begin(), deps.end(),
                                         [](const auto& dep){
        return (dep.startsWith("Components-"));
    });
    auto depComponentCount = std::distance(depsComponentsBegin, deps.end());
    if (depComponentCount > 0) {
        depsComponents.reserve(std::distance(depsComponentsBegin, deps.end()));
        std::move(depsComponentsBegin, deps.end(), std::back_inserter(depsComponents));
    }

    // Get depend equs
    ConstantDefinitions::DependencyEqus depEqus;
    for (auto& dep : deps) {
        dep = depEqus.fromPacket(dep);
    }

    // Setup main configuration string
    res += QString("COMPONENTS_CONFIGURE_COMPONENT_V2(%1 \"%2\"\n%3)").arg(
                                                                          m_componentName,
                                                                          m_pManifest->getVersion(),
                                                                          deps.join("\n")
                                                                          ).toUtf8();

    // Link to other components, if required
    for (auto& dep : depsComponents) {
        res += QString("COMPONENTS_LINK_COMPONENT(%1 %2)").arg(m_componentName, dep).toUtf8();
    }

    return res;
}
