#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFileInfo>
#include <signal.h>

void handleExitSignal(int sig) {
  printf("Exiting due to signal %d\n", sig);
  QCoreApplication::quit();
}

void setupSignalHandlers() {
#ifdef _WIN32
  signal(SIGINT, handleExitSignal);
#else
  struct sigaction sa;
  sa.sa_handler = handleExitSignal;
  sigset_t signal_mask;
  sigemptyset(&signal_mask);
  sa.sa_mask = signal_mask;
  sa.sa_flags = 0;
  sigaction(SIGINT, &sa, nullptr);
#endif
}

int main(int argc, char *argv[])
{
    setupSignalHandlers();

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
