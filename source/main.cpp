#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <boost/algorithm/algorithm.hpp>
#include <boost/algorithm/cxx11/is_sorted.hpp>

#include <boost/assert.hpp>

#include <CMakeConfig.hpp>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    int c[] = {1,2,3,4};

    bool ans = boost::algorithm::is_sorted(c);

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
