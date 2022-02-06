using System.Threading;
using System.Threading.Tasks;
using AuthServer.Services.DbServices.Interfaces;
using HotChocolate;

namespace AuthServer.GraphQL.EmailServer;

public class EmailServerQuery
{
    public async Task<Data.Models.EmailServer> GetEmailServer([Service] IEmailService service, CancellationToken cancellationToken)
    {
        return await service.GetServer(cancellationToken);
    }
}