using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text.Json;
using AuthServer.Configuration.Constants;
using AuthServer.Data.Models;
using AuthServer.Dtos;
using AuthServer.GraphQL.Client.Types.Inputs;
using AuthServer.GraphQL.Scope.Types.Inputs;
using AuthServer.GraphQL.User.Types;
using JetBrains.Annotations;
using Mapster;
using Microsoft.AspNetCore.Identity;
using OpenIddict.Abstractions;
using Serilog;

namespace AuthServer.Configuration
{
    public static class AuthServerTypeAdapterConfig
    {
        public static void Configure()
        {
            var cfg = TypeAdapterConfig.GlobalSettings;

            cfg.NewConfig<ApplicationUser, UserDto>()
                .AddDestinationTransform((string x) => x ?? "")
                .AddDestinationTransform((List<Claim> x) => x ?? new List<Claim>())
                .TwoWays()
                .MapToConstructor(true);

            cfg.NewConfig<ApplicationClient, ClientDto>()
                .Map(d => d.Id, s => s.Id)
                .Map(d => d.ClientId, s => s.ClientId ?? "")
                .Map(d => d.ClientSecret, s => s.ClientSecret ?? "")
                .Map(d => d.DisplayName, s => s.DisplayName ?? "")
                .Map(d => d.RequireConsent, s => s.ConsentType == OpenIddictConstants.ConsentTypes.Explicit)
                .Map(d => d.Type, s => s.Type ?? OpenIddictConstants.ClientTypes.Public)
                .Map(d => d.DisplayNames, s => MapFromJsonToListOfStrings(s.DisplayNames))
                .Map(d => d.Permissions, s => MapFromJsonToListOfStrings(s.Permissions).TakeWhile(p => p.StartsWith("scp:") || Predefined.Scopes.Contains(p)))
                .Map(d => d.RedirectUris, s => MapFromJsonToListOfStrings(s.RedirectUris))
                .Map(d => d.PostLogoutRedirectUris, s => MapFromJsonToListOfStrings(s.PostLogoutRedirectUris))
                .Map(d => d.RequireConsent, s => s.ConsentType == OpenIddictConstants.ConsentTypes.Explicit)
                .Map(d => d.RequirePkce, s => MapFromJsonToListOfStrings(s.Requirements).Contains(OpenIddictConstants.Requirements.Features.ProofKeyForCodeExchange));

            cfg.NewConfig<ClientInput, ApplicationClient>()
                .Map(d => d.Id, s => s.Id)
                .Map(d => d.ClientId, s => s.ClientId)
                .Map(d => d.DisplayNames, s => MapToJson(s.DisplayNames))
                .Map(d => d.Permissions, s => MapToJson(HandlePermissions(s).Permissions))
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
                .Map(d => d.Resources, s => MapFromJsonToListOfStrings(s.Resources))
                .AddDestinationTransform((string x) => x ?? "")
                .AddDestinationTransform((Guid x) => x != default ? x : Guid.Empty)
                .AddDestinationTransform((List<string> l) => l ?? new List<string>())
                .TwoWays();

            cfg.NewConfig<ScopeInput, ApplicationScope>()
                .Map(d => d.Name, s => s.Name.StartsWith("scp:") ? s.Name : $"{OpenIddictConstants.Permissions.Prefixes.Scope}{s.Name}")
                .Map(d => d.Resources, s => MapToJson(s.Resources));

            cfg.NewConfig<ApplicationAuthorization, AuthorizationDto>()
                .Map(d => d.Id, s => s.Id)
                .Map(d => d.Application, s => s.Application != null ? s.Application.Adapt<ClientDto>() : null)
                .Map(d => d.Status, s => s.Status)
                .Map(d => d.Subject, s => s.Subject ?? "")
                .Map(d => d.CreationDate, s => s.CreationDate)
                .Map(d => d.Type, s => s.Type ?? "")
                .Map(d => d.Scopes, s => MapFromJsonToListOfStrings(s.Scopes));
        }

        private static ClientInput HandlePermissions(ClientInput c)
        {
            return ConvertSettingsToPermissions(AddDefaultPermissions(PrepareCustomScopes(c)));
        }
        
        private static ClientInput PrepareCustomScopes(ClientInput s)
        {
            s.Permissions = s.Permissions.Select(scp => Predefined.Scopes.Contains(scp) ? scp : scp.StartsWith("scp:") ? scp : $"scp:{scp}").ToList();
            return s;
        }
        
        private static ClientInput AddDefaultPermissions(ClientInput c)
        {
            c.Permissions = c.Permissions.Concat(Predefined.ClientDefaults()).Distinct().ToList();
            return c;
        }

        private static ClientInput ConvertSettingsToPermissions(ClientInput c)
        {
            if (c.Type == OpenIddictConstants.ClientTypes.Confidential)
            {
                c.Permissions.Remove(OpenIddictConstants.GrantTypes.AuthorizationCode);
                c.Permissions.Remove(OpenIddictConstants.ResponseTypes.Code);
                c.Permissions.Remove(OpenIddictConstants.GrantTypes.Implicit);
                c.Permissions.Add(OpenIddictConstants.GrantTypes.ClientCredentials);
                c.Permissions.Add(OpenIddictConstants.ResponseTypes.Token);
            }

            if (c.Type == OpenIddictConstants.ClientTypes.Public)
            {
                c.Permissions.Remove(OpenIddictConstants.GrantTypes.ClientCredentials);
                c.Permissions.Remove(OpenIddictConstants.ResponseTypes.Token);
            }

            if (c.RequirePkce)
            {
                c.Permissions.Add(OpenIddictConstants.GrantTypes.AuthorizationCode);
                c.Permissions.Add(OpenIddictConstants.ResponseTypes.Code);
                c.Permissions.Remove(OpenIddictConstants.GrantTypes.Implicit);
            }
            else
            {
                c.Permissions.Remove(OpenIddictConstants.GrantTypes.AuthorizationCode);
                c.Permissions.Remove(OpenIddictConstants.ResponseTypes.Code);
                c.Permissions.Add(OpenIddictConstants.GrantTypes.Implicit);
            }

            return c;
        }

        private static List<string> MapFromJsonToListOfStrings([CanBeNull] string jsonValue)
        {
            if (string.IsNullOrEmpty(jsonValue)) 
                return new List<string>();
            try
            {
                var mapFromJsonToListOfStrings = JsonSerializer.Deserialize<List<string>>(jsonValue);
                return mapFromJsonToListOfStrings ?? new List<string>();
            }
            catch (JsonException e)
            {
                Log.Error(e, $"Unable to deserialize json: {jsonValue}");
            }
            return new List<string>();
        }

        private static string MapToJson(List<string> s)
        {
            return JsonSerializer.Serialize(s);
        }
    }
}