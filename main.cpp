#include <QApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    //TODO: Run this on Qt versions which support it...
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
