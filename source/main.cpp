// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <app_environment.hpp>
#include <import_qml_components_plugins.hpp>
#include <import_qml_plugins.hpp>

int main(int argc, char *argv[])
{
    set_qt_environment();

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    const QUrl url(u"qrc:/qt/qml/Main/main.qml"_qs);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");
    engine.addImportPath("qrc:/qt/qml/asset_imports/asset_imports_qml_module_dir_map.qrc");
    engine.addImportPath("qrc:/qt/qml/asset_imports/asset_imports/");
    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml/asset_imports/asset_imports/");
    engine.load(url);

    if (engine.rootObjects().isEmpty()) return -1;
    return app.exec();
}
