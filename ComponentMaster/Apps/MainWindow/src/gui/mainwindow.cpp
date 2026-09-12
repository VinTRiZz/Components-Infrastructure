#include "mainwindow.hpp"
#include "ui_mainwindow.h"

#include <Components/Logger/Logger.h>

#include "objects/componentscommonconfiguration.hpp"
#include "objects/mastercomponent.hpp"

#include "models/componentmodel.hpp"

#include <QFileInfo>
#include <QFileDialog>
#include <QMessageBox>

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

            for (int i = 0; i < m_pComponentModel->rowCount(); ++i) {
                m_pComponentModel->getComponent(i);
            }
        }
    });
}

MainWindow::~MainWindow()
{
    delete ui;
}