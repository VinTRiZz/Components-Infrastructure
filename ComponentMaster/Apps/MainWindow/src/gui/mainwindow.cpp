#include "mainwindow.hpp"
#include "ui_mainwindow.h"

#include <Components/Logger/Logger.h>

#include "objects/componentscommonconfiguration.hpp"
#include "objects/mastercomponent.hpp"

#include "models/componentmodel.hpp"

#include <QFileInfo>
#include <QFileDialog>
#include <QMessageBox>

#include "constantdefinitions.hpp"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    m_pCommonConfig = new ComponentsCommonConfiguration(this);

    m_pComponentModel = new ComponentModel(m_pCommonConfig, this);
    ui->comboBoxComponent->setModel(m_pComponentModel);

    connect(ui->lineEditRootPath, &QLineEdit::textChanged,
            this, [this](const auto& componentsRoot){
                auto fileInfo = QFileInfo(componentsRoot);
                if (fileInfo.exists() && fileInfo.isDir() && fileInfo.isReadable()) {
                    m_pCommonConfig->setRootDir(componentsRoot);
                    m_pComponentModel->setRoot(componentsRoot);
                    COMPLOG_OK("Component root directory changed to:", componentsRoot.toStdString());
                }
            });

    connect(ui->pushButtonComponentAdd, &QPushButton::clicked,
            this, [this](){
                // TODO: Download component
            });

    connect(ui->pushButtonComponentRemove, &QPushButton::clicked,
            this, [this](){
                auto userResponse = QMessageBox::warning(
                    this,
                    "Remove a component",
                    QString("Are you sure to remove component:\n%1").arg(ui->comboBoxComponent->currentText()),
                    QMessageBox::StandardButton::Yes,
                    QMessageBox::StandardButton::No
                    );
                if (QMessageBox::StandardButton::Yes != userResponse) {
                    return;
                }
                auto pComponent = m_pComponentModel->getComponent(ui->comboBoxComponent->currentIndex());
                if (pComponent) {
                    pComponent->deleteComponent();
                }
            });
}

MainWindow::~MainWindow()
{
    delete ui;
}