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
  // cout << "Hello World" << endl;
  // Docker d = {};
  //
  // auto res = d.listContainers();
  //
  // for (auto s : res) {
  //   cout << s << endl;
  // }
  //
  // string containerName =
  //     d.startContainer("marctv/minecraft-papermc-server:1.21.10-91");
  // cout << containerName << endl;
  // this_thread::sleep_for(chrono::milliseconds(3000));
  // d.stopContainer(containerName);

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
