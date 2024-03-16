#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <gtest/gtest.h>
#include <boost/algorithm/algorithm.hpp>

#include <CMakeConfig.hpp>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    const QUrl url(u"qrc:/Task-Management-App/source_gui/Main.qml"_qs);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
