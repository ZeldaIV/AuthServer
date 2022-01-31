using System.Collections.Generic;
using HotChocolate.Types;
using static OpenIddict.Abstractions.OpenIddictConstants;

namespace AuthServer.GraphQL.Options;

public class OptionsQuery
{
    public List<string> GetApplicationTypes()
    {
        return new List<string>
        {
            ClientTypes.Confidential,
            ClientTypes.Public
        };
    }
}

public class OptionsQueryExtensions : ObjectTypeExtension<OptionsQuery>
{
    protected override void Configure(IObjectTypeDescriptor<OptionsQuery> descriptor)
    {
        descriptor.Name("Query");

        descriptor.Field(q => q.GetApplicationTypes())
            .Type<NonNullType<ListType<NonNullType<StringType>>>>();
    }
}