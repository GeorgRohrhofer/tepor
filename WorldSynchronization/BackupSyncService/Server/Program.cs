using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;

class FileServer
{
    private const int Port = 5432;

    static void Main(string[] args)
    {
        Console.WriteLine("TCP File Server startet on Port " + Port);
        
        TcpListener server = new TcpListener(IPAddress.Any, Port);
        server.Start();
        
        Console.WriteLine("Waiting for Client-Connections...");

        while (true)
        {
            try
            {
                TcpClient client = server.AcceptTcpClient();
                Console.WriteLine($"Client connected: {((IPEndPoint?)client?.Client?.RemoteEndPoint)?.Address}");
                
                if (client == null)
                  continue;

                NetworkStream stream = client.GetStream();
                
                // Receive Filepath from Client
                byte[] buffer = new byte[4096];
                int bytesRead = stream.Read(buffer, 0, buffer.Length);
                string filePath = Encoding.UTF8.GetString(buffer, 0, bytesRead);
                
                Console.WriteLine($"Angeforderter Pfad: {filePath}");
                
                if (File.Exists(filePath))
                {
                    // Send OK 
                    byte[] confirmation = Encoding.UTF8.GetBytes("OK");
                    stream.Write(confirmation, 0, confirmation.Length);
                    
                    // Send Filename
                    string fileName = Path.GetFileName(filePath);
                    byte[] fileNameBytes = Encoding.UTF8.GetBytes(fileName);
                    stream.Write(BitConverter.GetBytes(fileNameBytes.Length), 0, 4);
                    stream.Write(fileNameBytes, 0, fileNameBytes.Length);
                    
                    // Send Filesize
                    FileInfo fileInfo = new FileInfo(filePath);
                    byte[] fileSizeBytes = BitConverter.GetBytes(fileInfo.Length);
                    stream.Write(fileSizeBytes, 0, fileSizeBytes.Length);
                    
                    // Send Filecontent
                    using (FileStream fileStream = File.OpenRead(filePath))
                    {
                        byte[] fileBuffer = new byte[8192];
                        int bytesReadFromFile;
                        long totalSent = 0;
                        
                        while ((bytesReadFromFile = fileStream.Read(fileBuffer, 0, fileBuffer.Length)) > 0)
                        {
                            stream.Write(fileBuffer, 0, bytesReadFromFile);
                            totalSent += bytesReadFromFile;
                            Console.Write($"\rSent: {totalSent}/{fileInfo.Length} bytes ({(totalSent * 100 / fileInfo.Length)}%)");
                        }
                    }
                    
                    Console.WriteLine("\nFile successfully sent!");
                }
                else if (Directory.Exists(filePath))
                {
                    // Send directory list
                    byte[] confirmation = Encoding.UTF8.GetBytes("DIR");
                    stream.Write(confirmation, 0, confirmation.Length);
                    
                    string[] files = Directory.GetFiles(filePath, "*", SearchOption.AllDirectories);
                    
                    // Send number of files
                    stream.Write(BitConverter.GetBytes(files.Length), 0, 4);
                    
                    foreach (string file in files)
                    {
                        string relativePath = file.Substring(filePath.Length).TrimStart(Path.DirectorySeparatorChar);
                        byte[] pathBytes = Encoding.UTF8.GetBytes(relativePath);
                        
                        // Send path length and path
                        stream.Write(BitConverter.GetBytes(pathBytes.Length), 0, 4);
                        stream.Write(pathBytes, 0, pathBytes.Length);
                        
                        // Send file size
                        FileInfo fi = new FileInfo(file);
                        stream.Write(BitConverter.GetBytes(fi.Length), 0, 8);
                        
                        // Send file content
                        using (FileStream fs = File.OpenRead(file))
                        {
                            byte[] fileBuffer = new byte[8192];
                            int count;
                            while ((count = fs.Read(fileBuffer, 0, fileBuffer.Length)) > 0)
                            {
                                stream.Write(fileBuffer, 0, count);
                            }
                        }
                        
                        Console.WriteLine($"Sent: {relativePath}");
                    }
                    
                    Console.WriteLine($"Successfully sent directory! ({files.Length} files)");
                }
                else
                {
                    // Fehler: Pfad existiert nicht
                    byte[] error = Encoding.UTF8.GetBytes("ERROR");
                    stream.Write(error, 0, error.Length);
                    Console.WriteLine("Error: Path does not exist!");
                }
                
                client.Close();
                Console.WriteLine("Connection closed.\n");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
