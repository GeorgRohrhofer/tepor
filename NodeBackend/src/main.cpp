#include <QCoreApplication>
#include <QEventLoop>
#include <QObject>
#include <QTimer>
#include <chrono>
#include <iostream>
#include <thread>

#include "NetworkManager.h"
#include "dockerlib.h"

using namespace std;

int main(int argc, char *argv[]) {
  QCoreApplication app(argc, argv);
  QEventLoop loop;

  NetworkManager *mng = new NetworkManager(nullptr);
  QObject::connect(mng, &NetworkManager::messageReceived, [&](QByteArray data) {
    cout << QString(data).toStdString() << endl;
    loop.quit();
  });

  mng->connectToServer("localhost", 8080);
  mng->waitForConnection();
  mng->sendMessage("test");

  loop.exec();

  return 0;
}
