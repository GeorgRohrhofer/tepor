using System;
using System.IO;
using System.Net.Sockets;
using System.Text;

class FileClient
{
    private const int Port = 5432;

    static void Main(string[] args)
    {
        if (args.Length != 2)
        {
            Console.WriteLine("Usage: FileClient <Server-IP> <Filepath>");
            Console.WriteLine("Example: FileClient 192.168.1.100 C:\\test\\datei.txt");
            return;
        }

        string serverIP = args[0];
        string filePath = args[1];

        try
        {
            Console.WriteLine($"Connecting to Server {serverIP}:{Port}...");
            
            TcpClient client = new TcpClient(serverIP, Port);
            NetworkStream stream = client.GetStream();
            
            Console.WriteLine("Connected! Sending Request...");
            
            int bytesCount;
            // Send filepath to server
            byte[] pathBytes = Encoding.UTF8.GetBytes(filePath);
            stream.Write(pathBytes, 0, pathBytes.Length);

            // Receive response from server
            byte[] responseBuffer = new byte[5];
            bytesCount = stream.Read(responseBuffer, 0, responseBuffer.Length);

            if (bytesCount == 0) 
            {
                return;
            }

            string response = Encoding.UTF8.GetString(responseBuffer);
            
            if (response.StartsWith("OK"))
            {
                // Receive single file
                ReceiveFile(stream, Path.GetFileName(filePath));
            }
            else if (response.StartsWith("DIR"))
            {
                // Receive directory
                ReceiveDirectory(stream, Path.GetFileName(filePath));
            }
            else if (response.StartsWith("ERROR"))
            {
                Console.WriteLine("Error: Given path does not exist!");
            }
            else
            {
                Console.WriteLine("Unknown response from server");
            }
            
            client.Close();
            Console.WriteLine("\nConnection closed.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
        }
    }

    static void ReceiveFile(NetworkStream stream, string fileName)
    {
        int bytesCount;
        // Receive file name length
        byte[] fileNameLengthBytes = new byte[4];
        bytesCount = stream.Read(fileNameLengthBytes, 0, 4);

        if (bytesCount == 0)
            return;

        int fileNameLength = BitConverter.ToInt32(fileNameLengthBytes, 0);
        
        // Receive file name
        byte[] fileNameBytes = new byte[fileNameLength];
        bytesCount = stream.Read(fileNameBytes, 0, fileNameLength);

        if (bytesCount == 0)
            return;

        string receivedFileName = Encoding.UTF8.GetString(fileNameBytes);
        
        // Receive file size
        byte[] fileSizeBytes = new byte[8];
        bytesCount = stream.Read(fileSizeBytes, 0, 8);

        if (bytesCount == 0)
            return;

        long fileSize = BitConverter.ToInt64(fileSizeBytes, 0);
        
        Console.WriteLine($"Empfange Datei: {receivedFileName} ({fileSize} bytes)");
        
        // Receive and store file
        string savePath = Path.Combine(Environment.CurrentDirectory, receivedFileName);
        using (FileStream fileStream = File.Create(savePath))
        {
            byte[] buffer = new byte[8192];
            long totalReceived = 0;
            int bytesRead;
            
            while (totalReceived < fileSize)
            {
                int toRead = (int)Math.Min(buffer.Length, fileSize - totalReceived);
                bytesRead = stream.Read(buffer, 0, toRead);
                
                if (bytesRead == 0)
                    break;
                
                fileStream.Write(buffer, 0, bytesRead);
                totalReceived += bytesRead;
                
                Console.Write($"\rProgress: {totalReceived}/{fileSize} bytes ({(totalReceived * 100 / fileSize)}%)");
            }
        }
        
        Console.WriteLine($"\nFile stored at: {savePath}");
    }

    static void ReceiveDirectory(NetworkStream stream, string dirName)
    {
        int bytesCount;
        // Receive number of files
        byte[] fileCountBytes = new byte[4];
        bytesCount = stream.Read(fileCountBytes, 0, 4);

        if (bytesCount == 0)
            return;

        int fileCount = BitConverter.ToInt32(fileCountBytes, 0);
        
        Console.WriteLine($"Receiving directory with {fileCount} Files...\n");
        
        // Create base directory
        string baseDir = Path.Combine(Environment.CurrentDirectory, dirName);
        Directory.CreateDirectory(baseDir);
        
        for (int i = 0; i < fileCount; i++)
        {
            // Receive path length
            byte[] pathLengthBytes = new byte[4];
            bytesCount = stream.Read(pathLengthBytes, 0, 4);

            if (bytesCount == 0)
                return;

            int pathLength = BitConverter.ToInt32(pathLengthBytes, 0);
            
            // Receive path
            byte[] pathBytes = new byte[pathLength];
            bytesCount = stream.Read(pathBytes, 0, pathLength);

            if (bytesCount == 0)
                return;

            string relativePath = Encoding.UTF8.GetString(pathBytes);
            
            // Receive file size
            byte[] fileSizeBytes = new byte[8];
            bytesCount = stream.Read(fileSizeBytes, 0, 8);

            if (bytesCount == 0)
                return;

            long fileSize = BitConverter.ToInt64(fileSizeBytes, 0);
            
            // Create full path
            string fullPath = Path.Combine(baseDir, relativePath);
            string? directory = Path.GetDirectoryName(fullPath);
            
            if (!string.IsNullOrEmpty(directory))
                Directory.CreateDirectory(directory);
            
            Console.WriteLine($"[{i + 1}/{fileCount}] receiving: {relativePath} ({fileSize} bytes)");
            
            // Receive file
            using (FileStream fs = File.Create(fullPath))
            {
                byte[] buffer = new byte[8192];
                long totalReceived = 0;
                
                while (totalReceived < fileSize)
                {
                    int toRead = (int)Math.Min(buffer.Length, fileSize - totalReceived);
                    int bytesRead = stream.Read(buffer, 0, toRead);
                    
                    if (bytesRead == 0)
                        break;
                    
                    fs.Write(buffer, 0, bytesRead);
                    totalReceived += bytesRead;
                }
            }
        }
        
        Console.WriteLine($"\nDirectory successfully received and stored at: {baseDir}");
    }
}
