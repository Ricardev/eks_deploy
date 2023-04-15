FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Services/DeployEksDemo/", "DeployEksDemo/"]
RUN dotnet restore "Services/DeployEksDemo/DeployEksDemo.csproj"
COPY . .
WORKDIR "/src/DeployEksDemo"
RUN dotnet build "DeployEksDemo.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DeployEksDemo.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DeployEksDemo.dll"]
