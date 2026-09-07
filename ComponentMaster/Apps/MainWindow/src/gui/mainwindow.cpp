#include "mainwindow.hpp"
#include "ui_mainwindow.h"

#include "objects/componentscommonconfiguration.hpp"
#include "objects/mastercomponent.hpp"

#include <QFileInfo>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    m_pCommonConfig = new ComponentsCommonConfiguration(this);

    connect(ui->lineEditRootPath, &QLineEdit::textEdited,
            this, [this](const auto& txt){
        auto fileInfo = QFileInfo(txt);
        if (fileInfo.exists() && fileInfo.isFile() || fileInfo.isDir()) {

        } else {

        }
    });
}

MainWindow::~MainWindow()
{
    delete ui;
}