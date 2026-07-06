---
name: delphi-rest-apis-horse
description: Desenvolvimento de microserviços e APIs REST com o framework minimalista Horse em Delphi. Rotas, controllers, middlewares e JSON.
---

# APIs REST e Microserviços com Horse no Delphi

Esta guia fornece padrões e convenções de arquitetura para projetar APIs REST de alta performance e código desacoplado utilizando o framework Horse.

## 1. Estrutura Padrão de Diretórios do Projeto
Organize o código de forma a separar a camada de tráfego HTTP da lógica de negócio e da infraestrutura de banco de dados:

```text
src/
├── MeuApp.dpr                          ← Arquivo de entrada do projeto
├── Controllers/
│   ├── MeuApp.Controller.Customer.pas   ← Registro de rotas e mapeamento de respostas
│   └── MeuApp.Controller.Health.pas     ← Endpoint de Health Check
├── Middleware/
│   └── MeuApp.Middleware.Auth.pas       ← Middleware de autorização customizado
├── Domain/
│   ├── MeuApp.Domain.Customer.Entity.pas
│   └── MeuApp.Domain.Customer.Repository.Intf.pas
├── Application/
│   └── MeuApp.Application.Customer.Service.pas
└── Infrastructure/
    └── MeuApp.Infra.Customer.Repository.pas
```

---

## 2. Configuração Básica do Servidor (DPR)
Registre os middlewares globais indispensáveis antes de expor os endpoints. Sempre ordene as sobrecargas dos middlewares:

```pascal
program MeuApp;

{$APPTYPE CONSOLE}

uses
  Horse,
  Horse.Jhonson,          // Middleware de serialização JSON
  Horse.CORS,             // Middleware de liberação de requisições Cross-Origin
  Horse.HandleException,  // Middleware para tratamento e formatação de erros
  MeuApp.Controller.Customer,
  MeuApp.Controller.Health;

begin
  // Registro de Middlewares Globais
  THorse.Use(Jhonson);
  THorse.Use(CORS);
  THorse.Use(HandleException);

  // Registro de Rotas (Controllers)
  TCustomerController.RegisterRoutes;
  THealthController.RegisterRoutes;

  // Escutar na porta configurada
  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor rodando com sucesso na porta 9000');
    end);
end.
```

---

## 3. Padrão de Controller
Os controllers atuam estritamente como a casca de entrega HTTP (Humble Object). Eles não devem conter queries SQL ou lógicas de negócio.

```pascal
unit MeuApp.Controller.Customer;

interface

uses
  Horse, System.JSON;

type
  TCustomerController = class
  public
    class procedure RegisterRoutes;
  private
    class procedure GetAll(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);
    class procedure GetById(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);
  end;

implementation

uses
  System.SysUtils,
  MeuApp.Application.Customer.Service;

class procedure TCustomerController.RegisterRoutes;
begin
  THorse.Get('/api/customers', GetAll);
  THorse.Get('/api/customers/:id', GetById);
end;

class procedure TCustomerController.GetAll(
  AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);
var
  LService: ICustomerService;
  LResult: TJSONArray;
begin
  LService := TCustomerService.Create;
  try
    LResult := LService.ListAll;
    ARes.Send<TJSONArray>(LResult).Status(THTTPStatus.OK);
  finally
    // Liberações se não forem injetadas por interface
  end;
end;

class procedure TCustomerController.GetById(
  AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);
var
  LService: ICustomerService;
  LId: Integer;
  LResult: TJSONObject;
begin
  LId := AReq.Params['id'].ToInteger;
  LService := TCustomerService.Create;
  
  LResult := LService.GetById(LId);
  if not Assigned(LResult) then
  begin
    ARes.Send('Cliente não encontrado').Status(THTTPStatus.NotFound);
    Exit;
  end;

  ARes.Send<TJSONObject>(LResult).Status(THTTPStatus.OK);
end;

end.
```

---

## 4. Pacotes Auxiliares e Middlewares do Ecossistema

Sempre utilize o gerenciador de dependências **Boss** (`boss install <pacote>`) para instalar extensões do Horse:

| Middleware / Pacote | Propósito | Comando de Instalação |
| :--- | :--- | :--- |
| `horse-jhonson` | Conversão e parsing automático de bodies e responses para JSON | `boss install horse-jhonson` |
| `horse-cors` | Habilita requisições Cross-Origin Resource Sharing | `boss install horse-cors` |
| `horse-handle-exception` | Captura exceptions internas não tratadas e as retorna como erro HTTP formatado | `boss install horse-handle-exception` |
| `horse-jwt` | Validação de Tokens JWT para autenticação | `boss install horse-jwt` |
| `horse-basic-auth` | Validação de autenticação clássica (Basic Auth) | `boss install horse-basic-auth` |
| `horse-octet-stream` | Middleware para upload/download seguro de arquivos binários | `boss install horse-octet-stream` |
