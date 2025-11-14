#include <QCoreApplication>
#include <QEventLoop>
#include <QObject>
#include <QTimer>
#include <iostream>
#include <stdexcept>

#include "NetworkManager.h"
#include "dockerlib.h"
#include "DatabaseManager.h"

using namespace std;

int main(int argc, char *argv[]) {
  QCoreApplication app(argc, argv);
  QEventLoop loop;
  DatabaseManager *db = new DatabaseManager();
  try {
    db->executeCommand("CREATE TABLE World (name TEXT, hash TEXT)");
  }
  catch (const std::runtime_error &e) {
    // Database setup has already been ran once
  }

  db->executeCommand("INSERT INTO World (name, hash) VALUES ('Worllld', '1234567890')");
  auto result = db->executeQuery("SELECT * FROM World");

  cout << result.size() << endl;

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
