package tepor.velocityplugin;

import com.velocitypowered.api.proxy.ProxyServer;
import com.velocitypowered.api.proxy.server.ServerInfo;
import java.io.*;
import java.net.*;
import java.nio.ByteBuffer;
import com.google.gson.Gson;

public class TeporProxy {
  public static final int PORT = 32823;
  private static final Gson gson = new Gson();

  private final ProxyServer server;
  private Thread thread;

  public TeporProxy(ProxyServer server) {
    this.server = server;
  }

  public void Start() {
    this.thread = new Thread(() -> this.Work());
    this.thread.start();
  }

  public void Stop() {

  }

  private void Work() {
    System.out.println("Tepor Proxy startet on Port " + PORT + "...");
        
    try (ServerSocket serverSocket = new ServerSocket(PORT)) {
      System.out.println("Tepor Proxy is running and waiting for connections...");
            
      while (true) {
        Socket clientSocket = serverSocket.accept();
        System.out.println("Client connected: " + clientSocket.getInetAddress());
                
        new Thread(() -> handleClient(clientSocket)).start();
      }
    } catch (IOException e) {
      System.err.println("Server Error: " + e.getMessage());
      e.printStackTrace();
    } 
  }

  private void handleClient(Socket socket) {
    try (DataInputStream in = new DataInputStream(socket.getInputStream())) {
      while (true) {
        try {
          byte version = in.readByte();
                    
          int length = in.readInt();
                    
          if (length <= 0 || length > 1024 * 1024) { // Max 1MB
            System.err.println("Received Message with invalid length: " + length);
            break;
          }
                    
          byte[] jsonBytes = new byte[length];
          in.readFully(jsonBytes);
          String jsonString = new String(jsonBytes, "UTF-8");
                   
          ServerMessage message = gson.fromJson(jsonString, ServerMessage.class);
        } catch (EOFException e) {
          System.out.println("Client disconnected");
          break;
        }
      }
    } catch (IOException e) {
      System.err.println("Client Error: " + e.getMessage());
    } finally {
      try {
        socket.close();
        System.out.println("Closed client connection");
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  private void RegisterServer(ServerMessage message) {
    ServerInfo serverInfo = new ServerInfo(
        message.getServerName(), 
        new InetSocketAddress(message.getIpAddress(), message.getPort())
        );

    server.registerServer(serverInfo);
  }
}
