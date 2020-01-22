FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /source

# copy everything else and build app
COPY . .
RUN dotnet restore && dotnet publish -c Debug -o out


FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS runtime
WORKDIR /app
COPY --from=build /source/out ./
ENTRYPOINT ["dotnet", "AuthServer.dll"]