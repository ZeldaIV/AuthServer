FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.csproj .
RUN dotnet restore

# copy everything else and build app
COPY . .
RUN dotnet publish -c Release -o out


FROM microsoft/dotnet:2.1-aspnetcore-runtime AS runtime
WORKDIR /app
COPY --from=build /source/out ./
COPY --from=build /source/wait-for-it.sh ./
RUN chmod +x ./wait-for-it.sh
# ENTRYPOINT ["dotnet", "AuthServer.dll"]