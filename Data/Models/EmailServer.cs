using System;

namespace AuthServer.Data.Models;

public class EmailServer
{
    public Guid Id { get; set; }
    public string Host { get; set; }
    public int Port { get; set; }
    public string UserName { get; set; }
    public string Password { get; set; }
    public string FromAddress { get; set; }
    public string FromDisplayName { get; set; }
    public string IV { get; set; }
}