using AuthServer.GraphQL.ApiResource;
using AuthServer.GraphQL.Client;
using AuthServer.GraphQL.Scope;
using AuthServer.GraphQL.User;
using AuthServer.Utilities;
using HotChocolate.Execution.Options;
using HotChocolate.Types;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace AuthServer.Extensions.Services
{
    public static class AddGraphQlExtensions
    {
        public static void AddGraphQlServices(this IServiceCollection services)
        {
            services.AddGraphQLServer().AddDiagnosticEventListener(sp =>
                    new ConsoleQueryLogger(
                        sp.GetApplicationService<ILogger<ConsoleQueryLogger>>()
                    ))
                .AddApolloTracing(TracingPreference.Always)
                .ModifyOptions(opts => { opts.RemoveUnreachableTypes = true; }).AddType(new UuidType('D', true))

                // Queries
                .AddQueryType(d => d.Name("Query"))
                .AddTypeExtension<AuthorizationTypeQueryExtension>()
                .AddTypeExtension<ClientTypeQueryExtension>()
                .AddTypeExtension<UserTypeQueryExtension>()
                .AddTypeExtension<ScopeTypeQueryExtension>()

                // Mutations
                .AddMutationType(d => d.Name("Mutation"))
                .AddTypeExtension<AuthorizationMutationTypeExtension>()
                .AddTypeExtension<UserMutationTypeExtension>()
                .AddTypeExtension<ScopeMutationTypeExtension>()
                .AddTypeExtension<ClientMutationTypeExtension>();
        }
    }
}