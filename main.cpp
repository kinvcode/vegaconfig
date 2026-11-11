#include <QApplication>
#include <QCursor>
#include <QEvent>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QWindow>

class WindowHoverFilter : public QObject
{
public:
    using QObject::QObject;

protected:
    bool eventFilter(QObject *watched, QEvent *event) override
    {
        if (event->type() == QEvent::Enter || event->type() == QEvent::Leave) {
            if (auto *window = qobject_cast<QWindow *>(watched))
                window->setProperty("pointerInside", event->type() == QEvent::Enter);
        }
        return QObject::eventFilter(watched, event);
    }
};

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setWindowIcon(QIcon(QStringLiteral(":/icons/app.ico")));
    QQuickWindow::setDefaultAlphaBuffer(true);
    QCoreApplication::setOrganizationName(QStringLiteral("Vega"));
    QCoreApplication::setApplicationName(QStringLiteral("vegaconfig"));
    QQuickStyle::setStyle(QStringLiteral("Fusion"));

    WindowHoverFilter hoverFilter;
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app,
                     [&hoverFilter](QObject *object, const QUrl &) {
        auto *window = qobject_cast<QWindow *>(object);
        if (!window)
            return;
        window->installEventFilter(&hoverFilter);
        window->setProperty("pointerInside", window->geometry().contains(QCursor::pos()));
    });
    engine.loadFromModule("vegaconfig", "Main");

    return app.exec();
}
