#include "DatabaseManager.h"

#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>

DatabaseManager::DatabaseManager() {
  db = QSqlDatabase::addDatabase("QSQLITE");
  db.setDatabaseName("/flyway/sqlite.db");
  
  if (!db.open()) {
    qCritical() << "Database error: " << db.lastError().text();
    throw std::runtime_error("Failed to open database");
  }
}

DatabaseManager::~DatabaseManager() {
  db.close();
}

std::vector<std::unordered_map<QString, QVariant>> DatabaseManager::executeQuery(QString query) {
  if (!db.isOpen()) {
    throw std::runtime_error("Database not open");
  }

  std::vector<std::unordered_map<QString, QVariant>> result;
  QSqlQuery q(db);

  if (!q.exec(query)) {
    qCritical() << "Query failed: " << q.lastError().text();
    qCritical() << "Query: " << query.toStdString();
    throw std::runtime_error("Query failed");
  }

  QSqlRecord rec = q.record();

  while (q.next()) {
    std::unordered_map<QString, QVariant> row;
    for (int i = 0; i < rec.count(); i++) {
      row[rec.fieldName(i)] = q.value(i);
    }
    result.push_back(row);
  }
  return result;
}

void DatabaseManager::executeCommand(QString query) {
  if (!db.isOpen()) {
    throw std::runtime_error("Database not open");
  }

  QSqlQuery q(db);
  if (!q.exec(query)) {
    qCritical() << "Query failed: " << q.lastError().text();
    qCritical() << "Query: " << query.toStdString();
    throw std::runtime_error("Query failed");
  }
}
