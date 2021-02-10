FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
WORKDIR /source

# copy everything else and build app
COPY *.csproj .
RUN dotnet restore 

COPY . .
RUN dotnet publish -c Debug -o out --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:5.0-focal AS runtime
WORKDIR /app
COPY --from=build /source/out ./
ENTRYPOINT ["dotnet", "AuthServer.dll"]