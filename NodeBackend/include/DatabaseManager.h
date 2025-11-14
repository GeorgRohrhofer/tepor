#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QSqlDatabase>
#include <bits/std_thread.h>
#include <vector>
#include <unordered_map>

class DatabaseManager
{
  private:
    QSqlDatabase db;
  public:
    DatabaseManager();
    ~DatabaseManager();

    std::vector<std::unordered_map<QString, QVariant>> executeQuery(QString query);
    void executeCommand(QString query);
};

#endif
