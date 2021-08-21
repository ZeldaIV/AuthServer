using System;

namespace AuthServer.Swagger
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Enum | AttributeTargets.Interface)]
    public class GenerateModelAttribute: Attribute
    {
        
    }
}