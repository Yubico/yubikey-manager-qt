#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFileInfo>

int main(int argc, char *argv[])
{

    QCoreApplication app(argc, argv);

    QString app_dir = app.applicationDirPath();
    QString main_qml = "/qml/main.qml";
    QString path_prefix;
    QString url_prefix;

    if (QFileInfo::exists(":" + main_qml)) {
        // Embedded resources
        path_prefix = ":";
        url_prefix = "qrc://";
    } else if (QFileInfo::exists(app_dir + main_qml)) {
        // Try relative to executable
        path_prefix = app_dir;
        url_prefix = app_dir;
    } else {  //Assume qml/main.qml in cwd.
        app_dir = ".";
        path_prefix = ".";
        url_prefix = ".";
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appDir", app_dir);
    engine.rootContext()->setContextProperty("urlPrefix", url_prefix);

    qputenv("PYTHONDONTWRITEBYTECODE", "1");

    engine.load(QUrl(url_prefix + main_qml));

    return app.exec();
}
