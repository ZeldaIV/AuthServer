using System.Net;
using System.Net.Mail;
using System.Threading;
using System.Threading.Tasks;

namespace AuthServer.Services.Email;

public class EmailSender
{
    public async Task SendMailAsync(string toAddress, CancellationToken cancellationToken)
    {
        var host = "url";
        var port = 578;
        var userName = "";
        var password = "";
        var serverAddress = "";
            
        
        var client = new SmtpClient(host, port);
        client.EnableSsl = true;
        client.Credentials = new NetworkCredential(userName, password);

        var to = new MailAddress(toAddress);
        var from = new MailAddress(serverAddress);
        var message = new MailMessage(from, to);
        message.Subject = "AuthServer: Set your password";
        message.Body = "<h1>Welcome to AuthServer</h1>" +
                       "<p>Click this link to set your password <a href=\"link\"></p>";
        message.IsBodyHtml = true;

        await client.SendMailAsync(message, cancellationToken);
    }
}