---
name: delphi-rest-apis-horse
description: Desenvolvimento de microserviços e APIs REST com o framework minimalista Horse em Delphi. Rotas, controllers, middlewares, gerenciamento de memória e tratamento de parâmetros.
---

# Diretrizes para Desenvolvimento de APIs REST com Horse no Delphi

Estas regras fornecem padrões e convenções de arquitetura para projetar APIs REST de alta performance, código desacoplado e livre de vazamentos de memória (*memory leaks*) utilizando o framework Horse.

---

## 1. Estrutura Padrão de Diretórios do Projeto
Organize o código separando a camada de transporte HTTP (Controllers) da lógica de negócios e da infraestrutura de acesso a dados (SOLID/Clean Architecture):

```text
src/
├── MeuApp.dpr                          ← Bootstrap do projeto
├── Controllers/
│   ├── MeuApp.Controller.Customer.pas   ← Mapeamento de rotas e respostas HTTP
│   └── MeuApp.Controller.Health.pas     ← Endpoint de verificação de saúde
├── Middleware/
│   └── MeuApp.Middleware.Auth.pas       ← Middlewares customizados
├── Domain/
│   ├── MeuApp.Domain.Customer.Entity.pas
│   └── MeuApp.Domain.Customer.Repository.Intf.pas
├── Application/
│   └── MeuApp.Application.Customer.Service.pas
└── Infrastructure/
    └── MeuApp.Infra.Customer.Repository.pas
```

---

## 2. Inicialização do Servidor (DPR Bootstrap)
No arquivo principal do projeto (`.dpr`), configure o console do Delphi e ative o roteador de alta performance baseado em **Radix Tree** (`UseRadixRouter`). Registre os middlewares globais em sua sequência correta antes de escutar a porta.

```pascal
program MeuApp;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,          // Middleware de serialização JSON
  Horse.CORS,             // Middleware para controle Cross-Origin
  Horse.HandleException,  // Middleware para tratamento global de exceções
  MeuApp.Controller.Customer,
  MeuApp.Controller.Health;

begin
  // 1. Ativação obrigatória do Radix Tree Router (Alta Performance)
  THorse.UseRadixRouter;

  // 2. Registro de Middlewares Globais (Atenção à ordem sequencial)
  THorse.Use(HandleException); // Captura exceções primeiro
  THorse.Use(CORS);
  THorse.Use(Jhonson);        // Processamento de JSON

  // 3. Registro de Rotas (Controllers)
  TCustomerController.RegisterRoutes;
  THealthController.RegisterRoutes;

  // 4. Iniciar Servidor (Sempre utilize a porta e o callback de escuta)
  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor executando na porta ' + THorse.Port.ToString);
    end);
end.
```

---

## 3. Ordem Crítica de Middlewares e Pipeline
A ordem de declaração dos middlewares influencia diretamente o ciclo de vida da requisição. Siga sempre o seguinte padrão de ordenação:
1. **Tratamento de Exceções e Logs (Primeiro)**: `HandleException`, loggers, etc. Devem ser registrados primeiro para capturar erros em middlewares subsequentes.
2. **Segurança e Headers**: `CORS`, `basic-auth`, `JWT`.
3. **Serialização e Descompactação**: `OctetStream`, `Jhonson`.
4. **Definição de Rotas**: Declaradas sempre **após** o registro de todos os middlewares globais.

---

## 4. Padrão de Controller (Humble Object)
Os controllers devem atuar apenas como a camada de entrada e saída HTTP (Humble Object). Eles nunca contêm queries SQL ou lógica de negócio diretamente.

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
  Horse.Commons,
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
  LResult := LService.ListAll;
  // O framework toma a propriedade do JSON e irá liberá-lo. Não faça Free.
  ARes.Send<TJSONArray>(LResult).Status(THTTPStatus.OK);
end;

class procedure TCustomerController.GetById(
  AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);
var
  LService: ICustomerService;
  LId: Integer;
  LResult: TJSONObject;
begin
  LId := AReq.Params.Field('id').AsInteger;
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

## 5. Regras Críticas de Gestão de Memória (Evitando Memory Leaks)

### 5.1 Propriedade de JSON (Middleware Johnson)
Quando o middleware `Jhonson` é utilizado, o framework assume a posse dos objetos JSON enviados.
*   **Regra de Ouro**: **NUNCA** chame `.Free` ou `FreeAndNil` em um `TJSONObject` ou `TJSONArray` após passá-lo para `Res.Send<T>`.
*   **Motivo**: A liberação manual do objeto provocará um erro de Double-Free (*Access Violation*) quando o middleware Johnson tentar destruí-lo no término do ciclo de vida da requisição.

### 5.2 Propriedade de Streams e Arquivos
Para o envio de arquivos e streams personalizados (`Res.SendFile`, `Res.Download`, `Res.Render`):
*   **Regra de Ouro**: **NUNCA** libere o objeto `TStream` (como `TFileStream`, `TMemoryStream`) manualmente após passá-lo para a resposta.
*   **Motivo**: A instância do `THorseResponse` assume a propriedade e fará a liberação automática do stream assim que o conteúdo for integralmente gravado no socket TCP.

---

## 6. Thread-Safety em Acesso a Dados
O Horse opera sob um modelo concorrente multithreaded (cada requisição HTTP é processada em uma thread separada).
*   **Regra de Ouro**: **NUNCA** compartilhe instâncias de conexões a bancos de dados (`TFDConnection`) ou componentes de query (`TFDQuery`) de forma global ou estática.
*   **Boas Práticas**:
    *   Sempre instancie as conexões e queries de forma local dentro do escopo de execução da requisição (dentro de blocos `try...finally`).
    *   Configure e utilize pools de conexões (ex: FireDAC Connection Pooling com `.Params.Add('Pooled=True')`) para reaproveitamento otimizado e seguro de conexões entre as threads.

```pascal
procedure GetCustomerHandler(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
begin
  LConnection := TFDConnection.Create(nil);
  LQuery := TFDQuery.Create(nil);
  try
    LConnection.ConnectionDefName := 'MeuPoolFireDAC';
    LConnection.Connected := True;
    
    LQuery.Connection := LConnection;
    LQuery.SQL.Text := 'SELECT * FROM CUSTOMERS WHERE ID = :ID';
    LQuery.ParamByName('ID').AsInteger := Req.Params.Field('id').AsInteger;
    LQuery.Open;
    
    Res.Send(LQuery.ToJSONArray);
  finally
    LQuery.Free;
    LConnection.Free; // Retorna a conexão com segurança para o pool
  end;
end;
```

---

## 7. Leitura e Validação Declarativa de Parâmetros
Evite ler dicionários de strings crus (ex: `Req.Params['id']`) e convertê-los manualmente. Utilize o helper `.Field()` para obter um `THorseCoreParamField`, o qual oferece conversão tipada e validação Fail-Fast integrada:

*   **Conversão de Tipos**: Use conversores fluentes como `AsInteger`, `AsBoolean`, `AsFloat`, `AsISO8601DateTime`, `AsStream` (para uploads multipart) e `AsString`.
*   **Validação de Obrigatoriedade**: Use o método `.Required` e `.RequiredMessage('Erro')` para interromper automaticamente a requisição e retornar status `400 (Bad Request)` caso o parâmetro esteja ausente:
    ```pascal
    var
      LEmail: string;
    begin
      LEmail := Req.Query.Field('email')
        .Required
        .RequiredMessage('O parâmetro query "email" é obrigatório.')
        .AsString;
    end;
    ```

---

## 8. Manipulação de Cookies
O Horse possui suporte a leitura e gravação em conformidade com a RFC 6265 através de um design agnóstico de provedor:
*   **Leitura de Cookies**: Utilize o helper de parâmetros:
    ```pascal
    var
      LSession: string;
    begin
      LSession := Req.Cookie.Field('session_token').AsString;
    end;
    ```
*   **Gravação de Cookies**: Grave e configure propriedades de segurança de cookies fluentemente na resposta:
    ```pascal
    uses Horse.Core.Cookie;

    procedure SetSessionHandler(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    begin
      Res.Cookie('session_id', 'token123')
        .Path('/')
        .HttpOnly(True)
        .Secure(True)
        .SameSite(TSameSite.ssLax);
      Res.Send('Sessão configurada');
    end;
    ```

---

## 9. Tratamento Estruturado de Erros (`EHorseException`)
Para retornar respostas de erro padronizadas em formato JSON e com status HTTP adequados, lance exceções do tipo `EHorseException`:

```pascal
uses Horse.Exception, Horse.Commons;

procedure QueryProductHandler(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LId: Integer;
begin
  LId := Req.Params.Field('id').AsInteger;
  if LId <= 0 then
    raise EHorseException.New
      .Status(THTTPStatus.BadRequest)
      .Error('Identificador de produto inválido.');

  if not ProductExists(LId) then
    raise EHorseException.New
      .Status(THTTPStatus.NotFound)
      .Error('Produto não localizado.')
      .Code(4041)
      .Detail('O ID solicitado não corresponde a nenhum produto ativo no catálogo.');
end;
```
Quando essa exceção é disparada, o middleware `HandleException` a intercepta e formata um JSON padronizado contendo `error`, `code` e `detail`.

---

## 10. Criação de Middlewares Customizados
A assinatura de um middleware requer os parâmetros `THorseRequest`, `THorseResponse` e o callback `Next: TProc`:

```pascal
procedure MeuMiddlewareCustom(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  // 1. Processamento antes de chegar ao controller
  Req.Headers.AddOrSetValue('X-Start-Time', DateTimeToStr(Now));
  
  // 2. Chama Next para seguir com o pipeline
  Next;
  
  // 3. Processamento após a conclusão do controller
  Res.Headers.AddOrSetValue('X-Process-Finished', 'True');
end;
```
*   **Interrupção Precoce**: Para interromper a execução do fluxo (ex: falha de autenticação), envie a resposta com o status HTTP correto e **NÃO** invoque a chamada de `Next`.

---

## 11. Referência de Skills Originais (Diretrizes Avançadas)
O framework Horse possui um conjunto completo de 7 skills de IA modulares e detalhadas no repositório de documentação local. Caso necessite implementar lógicas avançadas, consulte os seguintes arquivos correspondentes:

*   **Estrutura de Aplicação**: [horse-app-structure.md](file:///d:/Delphi/horse/doc/skills/horse-app-structure.md)
*   **Rotas e Agrupamentos**: [horse-routing.md](file:///d:/Delphi/horse/doc/skills/horse-routing.md)
*   **Configuração de Middlewares**: [horse-middlewares.md](file:///d:/Delphi/horse/doc/skills/horse-middlewares.md)
*   **Payloads (Request/Response)**: [horse-request-response.md](file:///d:/Delphi/horse/doc/skills/horse-request-response.md)
*   **Manipulação de Arquivos e Streams**: [horse-files-streams.md](file:///d:/Delphi/horse/doc/skills/horse-files-streams.md)
*   **Provedores de Servidor (Providers)**: [horse-providers.md](file:///d:/Delphi/horse/doc/skills/horse-providers.md)
*   **Criação de Middlewares**: [horse-writing-middleware.md](file:///d:/Delphi/horse/doc/skills/horse-writing-middleware.md)
