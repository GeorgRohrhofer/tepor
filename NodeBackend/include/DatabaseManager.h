#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QSqlDatabase>
#include <vector>
#include <unordered_map>

class DatabaseManager
{
  private:
    QSqlDatabase db;
    
  
  public:
    DatabaseManager(QString path);
    ~DatabaseManager();

    std::vector<std::unordered_map<QString, QVariant>> executeQuery(QString query);
    std::vector<std::unordered_map<QString, QVariant>> executeQuery(QString query, std::vector<QVariant> params);
    void executeCommand(QString query);
    void executeCommand(QString query, std::vector<QVariant> params);
    std::vector<std::unordered_map<QString, QVariant>> getAllWorlds();
    void addWorld(int id, QString name, QString hash, QString config);
    void updateWorld(QString name, QString hash, QString config);
};

#endif
