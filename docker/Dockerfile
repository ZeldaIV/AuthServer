FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /source

# copy everything else and build app
COPY . .
RUN dotnet restore && dotnet publish -c Debug -o out


FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime
WORKDIR /app
COPY --from=build /source/out ./
ENTRYPOINT ["dotnet", "AuthServer.dll"]