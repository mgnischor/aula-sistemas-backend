# Use a imagem oficial do .NET 9.0 SDK para build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Copie os arquivos de projeto primeiro (para cache de dependências)
COPY *.csproj ./
COPY *.sln ./

# Restaure as dependências
RUN dotnet restore

# Copie o resto dos arquivos
COPY . ./

# Build da aplicação
RUN dotnet publish -c Release -o out

# Use a imagem runtime para produção
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Copie os arquivos publicados
COPY --from=build /app/out .

# Exponha a porta 8080 (padrão do ASP.NET Core no Docker)
EXPOSE 8080

# Configure variáveis de ambiente
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Ponto de entrada
ENTRYPOINT ["dotnet", "aula-sistemas-backend.dll"]