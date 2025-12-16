# syntax=docker/dockerfile:1.4

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS buildARG TARGETARCH
WORKDIR /src

RUN dotnet nuget locals all --clear

COPY . .
RUN dotnet restore
RUN dotnet publish -c Release -o /app/out --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=build /app/out .

# Document internal ports
EXPOSE 4444
EXPOSE 5278

ENTRYPOINT ["dotnet", "ManagementBackend.dll"]
