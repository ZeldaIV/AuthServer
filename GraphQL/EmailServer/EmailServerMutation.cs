using System;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.GraphQL.EmailServer.Types.Inputs;
using AuthServer.GraphQL.EmailServer.Types.Payloads;
using AuthServer.Services.DbServices.Interfaces;
using HotChocolate;
using Mapster;

namespace AuthServer.GraphQL.EmailServer;

public class EmailServerMutation
{
    public async Task<EmailServerPayload> CreateEmailServerAsync([Service] IEmailService service,
        CreateEmailServerInput input, CancellationToken cancellationToken)
    {
        var emailServer = input.Adapt<Data.Models.EmailServer>();
        emailServer.Id = emailServer.Id == default ? Guid.NewGuid() : emailServer.Id;
        await service.CreateAsync(emailServer, cancellationToken);

        return input.Adapt<EmailServerPayload>();
    }

    public async Task<EmailServerPayload> UpdateEmailServerAsync([Service] IEmailService service,
        UpdateEmailServerInput input, CancellationToken cancellationToken)
    {
        var emailServer = input.Adapt<Data.Models.EmailServer>();

        await service.UpdateAsync(emailServer, cancellationToken);

        return input.Adapt<EmailServerPayload>();
    }
}