#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    //TODO: Run this on Qt versions which support it...
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appDir", app.applicationDirPath());
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
