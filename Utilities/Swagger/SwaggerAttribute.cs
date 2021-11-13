using System;

namespace AuthServer.Utilities.Swagger
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Enum | AttributeTargets.Interface)]
    public class GenerateModelAttribute: Attribute
    {
        
    }
}