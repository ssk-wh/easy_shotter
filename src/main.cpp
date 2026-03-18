#include <QApplication>
#include <QSystemTrayIcon>
#include <QMessageBox>
#include "ui/main_window.h"

#ifdef Q_OS_WIN
#include <windows.h>
#endif

int main(int argc, char* argv[])
{
    // Enable per-monitor DPI scaling for correct rendering on multi-monitor setups
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

#ifdef Q_OS_WIN
    // Single instance check using named mutex
    HANDLE hMutex = CreateMutexW(nullptr, FALSE, L"SimpleShotter_SingleInstance_Mutex");
    if (GetLastError() == ERROR_ALREADY_EXISTS) {
        // Another instance is running, send it a message to trigger capture
        // FindWindowExW with HWND_MESSAGE is required to find message-only windows
        HWND hwnd = FindWindowExW(HWND_MESSAGE, nullptr, L"SimpleShotter_HiddenWindow", nullptr);
        if (hwnd) {
            UINT msg = RegisterWindowMessageW(L"SimpleShotter_StartCapture");
            PostMessageW(hwnd, msg, 0, 0);
        }
        CloseHandle(hMutex);
        return 0;
    }
#endif

    QApplication app(argc, argv);
    app.setApplicationName("SimpleShotter");
    app.setApplicationVersion("0.2.0");
    app.setQuitOnLastWindowClosed(false);

    if (!QSystemTrayIcon::isSystemTrayAvailable()) {
        QMessageBox::critical(nullptr, "SimpleShotter",
            "System tray is not available on this system.");
        return 1;
    }

    simpleshotter::MainWindow mainWindow;

    int ret = app.exec();

#ifdef Q_OS_WIN
    if (hMutex) {
        CloseHandle(hMutex);
    }
#endif
    return ret;
}
