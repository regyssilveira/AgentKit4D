# Manual de APIs REST com Horse no Delphi

Este manual apresenta as diretrizes para desenvolvimento de microserviços e APIs Web de alto desempenho utilizando o framework minimalista **Horse**, abordando roteamento, controladores, ciclo de vida de memória e gerenciamento de concorrência.

---

## 1. Padrão Controller e Isolamento de Rotas (Humble Object)
Evite declarar lógica de negócios ou consultas SQL diretamente no ponto de entrada do servidor (`.dpr`). Encapsule a infraestrutura de tráfego HTTP em classes do tipo `Controller` dedicadas e limpas, desacoplando-as das camadas internas de serviços e repositórios.

### Exemplo Prático de Organização:

1. **O Controller (`MeuApp.Controller.Customer.pas`)**:
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
  // O framework gerencia e destrói o JSON. NÃO faça Free.
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

2. **O Ponto de Entrada da API (`MeuApp.dpr`)**:
```pascal
program MeuApp;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  Horse.HandleException,
  MeuApp.Controller.Customer;

begin
  // 1. Otimiza o roteamento com Radix Tree Router
  THorse.UseRadixRouter;

  // 2. Registro do pipeline de Middlewares
  THorse.Use(HandleException);
  THorse.Use(CORS);
  THorse.Use(Jhonson);

  // 3. Registrar rotas do controlador
  TCustomerController.RegisterRoutes;

  // 4. Escuta da porta
  THorse.Listen(9000);
end.
```

---

## 2. Ordem Crítica de Middlewares (Pipeline)
A ordem de registro dos middlewares no `THorse` é altamente crítica e determina como as requisições fluem. Registre-os **sempre** antes de definir qualquer rota:
1. **Erros e Logs (Primeiro)**: `HandleException` e logs customizados devem abrir o pipeline para capturar falhas em qualquer middleware posterior.
2. **Segurança e Headers**: `CORS`, autorizações básicas ou JWT.
3. **Serializações e Parsers**: `OctetStream` (arquivos) e `Jhonson` (JSON).

---

## 3. Gestão de Memória e Prevenção de Memory Leaks

### 3.1 Transmissão de Propriedade de JSON (Johnson)
Quando você utiliza o middleware `Jhonson` e envia objetos JSON no corpo da resposta:
*   > [!WARNING]
    > **NUNCA** chame `.Free` ou `FreeAndNil` em instâncias de `TJSONObject` ou `TJSONArray` após passá-las para `Res.Send<T>`.
*   **Por quê?**: O middleware Johnson assume a custódia do objeto e se encarrega de destruí-lo automaticamente assim que a resposta HTTP é enviada. Liberá-lo no controller causa erro de Double-Free (*Access Violation*).

### 3.2 Transmissão de Propriedade de Streams e Arquivos
Ao enviar arquivos e streams binários via `Res.SendFile` ou `Res.Download`:
*   > [!WARNING]
    > **NUNCA** libere o objeto `TStream` manualmente após passá-lo para os métodos de resposta do Horse.
*   **Por quê?**: O framework assume a responsabilidade e fará a desalocação do stream de dados de forma assíncrona assim que a gravação no socket de rede for finalizada.

---

## 4. Concorrência e Conexões de Banco de Dados (Thread-Safety)
O Horse executa cada requisição em uma thread secundária de forma concorrente.
*   > [!CAUTION]
    > **NUNCA** compartilhe uma mesma conexão global de banco de dados (`TFDConnection`) ou componentes de query (`TFDQuery`) entre rotas/requisições.
*   **Solução Recomendada**: Instancie a conexão e os componentes de query localmente em blocos `try...finally` dentro de cada requisição. Sempre ative a propriedade de **Connection Pooling** do FireDAC (ex: configurando `Pooled=True` nos parâmetros de conexão) para melhor performance sob carga concorrente.

---

## 5. Validação Declarativa de Parâmetros
Em vez de ler dicionários cruas (`Req.Params['id']`) e fazer cast manual, utilize a API fluente do `.Field()` para validação e conversão automatizada:
```pascal
var
  LId: Integer;
  LEmail: string;
begin
  LId := Req.Params.Field('id').AsInteger;
  
  // Lança automaticamente EHorseException (400 Bad Request) se ausente
  LEmail := Req.Query.Field('email')
    .Required
    .RequiredMessage('O e-mail é obrigatório.')
    .AsString;
end;
```

---

## 6. Tratamento Estruturado de Erros (`EHorseException`)
Utilize exceções estruturadas da classe `EHorseException` para abortar fluxos incorretos e devolver erros padronizados em JSON:
```pascal
if not ProductExists(LId) then
  raise EHorseException.New
    .Status(THTTPStatus.NotFound)
    .Error('Produto não cadastrado.')
    .Code(4042)
    .Detail('O código informado não foi localizado no estoque.');
```

---

## 7. Documentação para IA e Referências Avançadas
Para referência técnica detalhada e suporte na escrita automática de códigos com agentes de IA, consulte as skills de IA em inglês localizadas no diretório do repositório:

*   **[horse-app-structure](file:///d:/Delphi/horse/doc/skills/horse-app-structure.md)**: Inicialização e bootstrapper do servidor console.
*   **[horse-routing](file:///d:/Delphi/horse/doc/skills/horse-routing.md)**: Parâmetros dinâmicos e curingas em rotas.
*   **[horse-middlewares](file:///d:/Delphi/horse/doc/skills/horse-middlewares.md)**: Pipeline, sequenciamento e liberação automática do Johnson.
*   **[horse-request-response](file:///d:/Delphi/horse/doc/skills/horse-request-response.md)**: Leitura de corpos de requisição, cookies e cabeçalhos.
*   **[horse-files-streams](file:///d:/Delphi/horse/doc/skills/horse-files-streams.md)**: Uploads multipart, download e propriedade de streams de arquivo.
*   **[horse-providers](file:///d:/Delphi/horse/doc/skills/horse-providers.md)**: Adaptadores do servidor de rede (Indy, HTTP.sys, ISAPI).
*   **[horse-writing-middleware](file:///d:/Delphi/horse/doc/skills/horse-writing-middleware.md)**: Escrita de interceptores e middlewares customizados.
