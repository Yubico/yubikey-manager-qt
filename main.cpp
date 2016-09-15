#include <QApplication>
#include <QQmlApplicationEngine>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    //TODO: Run this on Qt versions which support it...
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    setenv("DYLD_LIBRARY_PATH", app.applicationDirPath().toLatin1().data(), 1);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
