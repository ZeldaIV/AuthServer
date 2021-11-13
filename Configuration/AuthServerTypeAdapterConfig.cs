using System;
using System.Collections.Generic;
using System.Text.Json;
using AuthServer.Data.Models;
using AuthServer.Dtos;
using AuthServer.GraphQL.Client.Types.Inputs;
using JetBrains.Annotations;
using Mapster;
using Microsoft.AspNetCore.Identity;
using NuGet.Protocol;
using OpenIddict.Abstractions;
using Serilog;

namespace AuthServer.Configuration
{
    public static class AuthServerTypeAdapterConfig
    {
        public static void Configure()
        {
            var cfg = TypeAdapterConfig.GlobalSettings;

            cfg.NewConfig<IdentityUser, UserDto>()
                .AddDestinationTransform((string x) => x ?? "");

            cfg.NewConfig<ApplicationClient, ClientDto>()
                .Map(d => d.Authorizations,
                    s => s.Authorizations != null ? s.Authorizations.Adapt<AuthorizationDto>() : null)
                .Map(d => d.ClientId, s => s.ClientId != null ? Guid.Parse(s.ClientId) : Guid.Empty)
                .Map(d => d.ClientSecret, s => s.ClientSecret ?? "")
                .Map(d => d.DisplayName, s => s.DisplayName ?? "")
                .Map(d => d.RequireConsent, s => s.ConsentType == OpenIddictConstants.ConsentTypes.Explicit)
                .Map(d => d.Type, s => s.Type ?? "")
                .Map(d => d.DisplayNames, s => MapFromJsonToListOfStrings(s.DisplayNames))
                .Map(d => d.Permissions, s => MapFromJsonToListOfStrings(s.Permissions))
                .Map(d => d.RedirectUris, s => MapFromJsonToListOfStrings(s.RedirectUris))
                .Map(d => d.PostLogoutRedirectUris, s => MapFromJsonToListOfStrings(s.PostLogoutRedirectUris))
                .Map(d => d.RequireConsent, s => s.ConsentType == OpenIddictConstants.ConsentTypes.Explicit);

            cfg.NewConfig<ClientInput, ApplicationClient>()
                .Map(d => d.Id, s => s.ClientId)
                .Map(d => d.DisplayNames, s => MapToJson(s.DisplayNames))
                .Map(d => d.Permissions, s => MapToJson(s.Permissions))
                .Map(d => d.RedirectUris, s => MapToJson(s.RedirectUris))
                .Map(d => d.PostLogoutRedirectUris, s => MapToJson(s.PostLogoutRedirectUris))
                .Map(d => d.ConsentType,
                    s => s.RequireConsent
                        ? OpenIddictConstants.ConsentTypes.Explicit
                        : OpenIddictConstants.ConsentTypes.Implicit)
                .Map(d => d.Requirements,
                    s => s.RequirePkce
                        ? MapToJson(new List<string>
                        {
                            OpenIddictConstants.Requirements.Features.ProofKeyForCodeExchange
                        })
                        : null);


            cfg.NewConfig<ApplicationScope, ScopeDto>()
                .AddDestinationTransform((string x) => x ?? "")
                .AddDestinationTransform((Guid x) => x != null ? x : Guid.Empty)
                .TwoWays();

            cfg.NewConfig<ApplicationAuthorization, AuthorizationDto>()
                .Map(d => d.Id, s => s.Id)
                .Map(d => d.Application, s => s.Application != null ? s.Application.Adapt<ClientDto>() : null)
                .Map(d => d.Status, s => s.Status)
                .Map(d => d.Subject, s => s.Subject ?? "")
                .Map(d => d.CreationDate, s => s.CreationDate)
                .Map(d => d.Type, s => s.Type ?? "")
                .Map(d => d.Scopes, s => MapFromJsonToListOfStrings(s.Scopes));

            // cfg.NewConfig<Client, ClientDto>()
            //     .AddDestinationTransform((string x) => x ?? "")
            //     .AddDestinationTransform((List<string> c) => c ?? new List<string>())
            //     .AddDestinationTransform((List<ScopeDto> c) => c ?? new List<ScopeDto>());
        }

        private static List<string> MapFromJsonToListOfStrings([CanBeNull] string jsonValue)
        {
            if (!string.IsNullOrEmpty(jsonValue))
            {
                try
                {
                    var mapFromJsonToListOfStrings = JsonSerializer.Deserialize<List<string>>(jsonValue);
                    return mapFromJsonToListOfStrings ?? new List<string>();
                }
                catch (JsonException e)
                {
                    Log.Error(e, $"Unable to deserialize json: {jsonValue}");
                }
            }

            Log.Error("We are not supposed to end up here");
            return new List<string>();
        }

        private static string MapToJson(List<string> s)
        {
            return JsonSerializer.Serialize(s);
        }
    }
}