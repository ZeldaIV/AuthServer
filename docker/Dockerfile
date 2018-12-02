FROM microsoft/dotnet:2.1.500-sdk AS build
WORKDIR /source

# copy everything else and build app
COPY . .
RUN dotnet restore && dotnet publish -c Debug -o out


FROM microsoft/dotnet:2.1.6-aspnetcore-runtime AS runtime
WORKDIR /app
COPY --from=build /source/out ./
ENTRYPOINT ["dotnet", "AuthServer.dll"]