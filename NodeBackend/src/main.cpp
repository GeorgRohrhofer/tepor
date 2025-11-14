#include <QCoreApplication>
#include <QEventLoop>
#include <QObject>
#include <QTimer>
#include <iostream>
#include <stdexcept>
#include <CLI/CLI.hpp>

#include "NetworkManager.h"
#include "dockerlib.h"
#include "DatabaseManager.h"

using namespace std;

int main(int argc, char *argv[]) {
  // CLI setup
  CLI::App cliApp{"NodeBackend"};
  
  string dbPath = "/flyway/sqlite.db"; 
  cliApp.add_option("-d, --database", dbPath, "Path to the sqlite database");

  CLI11_PARSE(cliApp, argc, argv);

  QCoreApplication app(argc, argv);
  QEventLoop loop;
  DatabaseManager *db = new DatabaseManager(QString(dbPath.c_str()));

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

  delete mng;
  delete db;
  return 0;
}
