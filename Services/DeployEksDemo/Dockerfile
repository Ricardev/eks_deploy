FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
EXPOSE 5042

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src 
COPY . Services/DeployEksDemo/
RUN dotnet restore "Services/DeployEksDemo/DeployEksDemo.csproj"


FROM build AS publish
WORKDIR "/src/Services/DeployEksDemo"
RUN dotnet publish "DeployEksDemo.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DeployEksDemo.dll"]
