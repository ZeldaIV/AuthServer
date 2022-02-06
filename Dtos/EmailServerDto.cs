namespace AuthServer.Dtos;

public class EmailServerDto
{
    public string Host { get; set; }
    public int Port { get; set; }
    public string UserName { get; set; }
    public string FromAddress { get; set; }
    public string FromDisplayName { get; set; }
}