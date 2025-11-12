#ifndef NETWORK_MANAGER_H
#define NETWORK_MANAGER_H

#include<QTcpSocket>

class NetworkManager : public QObject {
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();
    void connectToServer(const QString &host, quint16 port);
    void sendMessage(const QByteArray &data);
    void waitForConnection();
    void disconnect();
    
signals:
    void connected();
    void disconnected();
    void messageReceived(const QByteArray &data);
    void errorOccurred(const QString &error);
    
private slots:
    void onConnected();
    void onDisconnected();
    void onReadyRead();
    void onError(QAbstractSocket::SocketError);
    
private:
    QTcpSocket *socket;
    QByteArray buffer; // For handling partial messages
};

#endif
