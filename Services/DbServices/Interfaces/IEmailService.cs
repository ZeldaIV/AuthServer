using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data.Models;

namespace AuthServer.Services.DbServices.Interfaces;

public interface IEmailService
{
    Task CreateAsync(EmailServer server, CancellationToken cancellationToken);
    Task<EmailServer> GetServer(CancellationToken cancellationToken);
    Task UpdateAsync(EmailServer update, CancellationToken cancellationToken);
}