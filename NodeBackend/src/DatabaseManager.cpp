#include "DatabaseManager.h"

#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>

DatabaseManager::DatabaseManager(QString path) {
  db = QSqlDatabase::addDatabase("QSQLITE");
  db.setDatabaseName(path);
  
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

std::vector<std::unordered_map<QString, QVariant>> DatabaseManager::executeQuery(QString query, std::vector<QVariant> params) {
  if (!db.isOpen()) {
    throw std::runtime_error("Database not open");
  }

  std::vector<std::unordered_map<QString, QVariant>> result;
  QSqlQuery q(db);

  if (!q.prepare(query)) { 
    qCritical() << "Prepare failed:" << q.lastError().text(); 
    throw std::runtime_error("Prepare failed");
  }

  for (const QVariant &p : params) {
    q.addBindValue(p);
  }

  if (!q.exec()) {
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

void DatabaseManager::executeCommand(QString query, std::vector<QVariant> params) {
  if (!db.isOpen()) {
    throw std::runtime_error("Database not open");
  }

  QSqlQuery q(db);
  if (!q.prepare(query)) { 
    qCritical() << "Prepare failed:" << q.lastError().text(); 
    throw std::runtime_error("Prepare failed");
  }

  for (const QVariant &p : params) {
    q.addBindValue(p);
  }

  if (!q.exec()) {
    qCritical() << "Query failed: " << q.lastError().text();
    qCritical() << "Query: " << query.toStdString();
    throw std::runtime_error("Query failed");
  }
}

std::vector<std::unordered_map<QString, QVariant>> DatabaseManager::getAllWorlds() {
  QString query = "SELECT * FROM World";
  return executeQuery(query);
}

void DatabaseManager::addWorld(int id, QString name, QString hash, QString config) {
  QString query = "INSERT INTO World (id, name, hash, config) VALUES (?, ?, ?, ?)";

  return executeCommand(query, std::vector<QVariant>{id, name, hash, config});
}

void DatabaseManager::updateWorld(QString name, QString hash, QString config) {
  QString query = "UPDATE World SET name = ?, hash = ?, config = ? WHERE name = ?";
  return executeCommand(query, std::vector<QVariant>{name, hash, config, name});
}
