# Manual de APIs REST com Horse no Delphi

Este manual apresenta as diretrizes para desenvolvimento de microserviços e APIs Web utilizando o framework minimalista **Horse**, abordando rotas, controladores e o pipeline de middlewares essenciais.

---

## 1. Padrão Controller e Isolamento de Rotas
Evite declarar a lógica de negócio ou queries de banco diretamente no arquivo de definição de rotas principal (`.dpr`). Crie classes ou procedures controladoras (`Controllers`) específicas para separar a infraestrutura HTTP da lógica da aplicação.

### Exemplo de Estrutura de Controller
1. **O Controller (`Controller.Product.pas`)**:
```delphi
unit Controller.Product;

interface

uses
  Horse;

type
  TProductController = class
  public
    class procedure RegisterRoutes;
    class procedure GetProducts(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  System.JSON;

class procedure TProductController.RegisterRoutes;
begin
  THorse.Get('/products', GetProducts);
end;

class procedure TProductController.GetProducts(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  var LJSONArray := TJSONArray.Create;
  try
    LJSONArray.Add(TJSONObject.Create(TJSONPair.Create('name', 'Product A')));
    LJSONArray.Add(TJSONObject.Create(TJSONPair.Create('name', 'Product B')));
    
    Res.Send<TJSONArray>(LJSONArray); // O middleware Johnson cuidará da liberação do JSON
  except
    on E: Exception do
    begin
      Res.Send(E.Message).Status(500);
    end;
  end;
end;

end.
```

2. **O Ponto de Entrada da API (`MyAPI.dpr`)**:
```delphi
program MyAPI;

{$APPTYPE CONSOLE}

uses
  Horse,
  Controller.Product;

begin
  // Registrar rotas do controlador
  TProductController.RegisterRoutes;

  // Iniciar servidor na porta 9000
  THorse.Listen(9000);
end.
```

---

## 2. Middlewares Essenciais (Pipeline)
Para construir APIs robustas e prontas para produção, configure obrigatoriamente os seguintes middlewares no início da inicialização do Horse:

*   **`Jhonson`**: Responsável pelo parse automático de requisições e respostas em JSON (`TJSONObject` / `TJSONArray`). Ele também gerencia a destruição do JSON enviado pelo método `Res.Send<T>`, evitando vazamento de memória.
*   **`CORS`**: Middleware de controle de compartilhamento de recursos de origem cruzada. Essencial se a sua API Delphi for consumida por frontends web em domínios diferentes (como Angular, React ou Vue).
*   **`HandleException`**: Captura exceções não tratadas no fluxo de execução do controller e devolve automaticamente uma resposta HTTP padronizada (ex: Status 500 com a mensagem do erro estruturada em JSON), prevenindo a queda silenciosa do serviço console.

```delphi
uses
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  Horse.HandleException;

begin
  // Pipeline de Middlewares configurado no início do bootstrap
  THorse
    .Use(CORS)
    .Use(Jhonson)
    .Use(HandleException);
    
  // ... registro de rotas ...
end.
```

---

## 3. Documentação de IA e Referências Avançadas
Para guiar coding assistants de IA ou encontrar referências de desenvolvimento altamente específicas, o repositório oficial do Horse conta com 6 skills modulares na pasta `$(HORSE)\doc\skills\`:

*   **[horse-app-structure](file:///d:/delphi/horse/doc/skills/horse-app-structure.md)**: Inicialização e bootstrap de rotinas console.
*   **[horse-routing](file:///d:/delphi/horse/doc/skills/horse-routing.md)**: Parâmetros dinâmicos e curingas em rotas.
*   **[horse-middlewares](file:///d:/delphi/horse/doc/skills/horse-middlewares.md)**: Lógica do pipeline e liberação de memória de JSONs (Johnson).
*   **[horse-request-response](file:///d:/delphi/horse/doc/skills/horse-request-response.md)**: Leitura de payloads, parâmetros de query e cookies.
*   **[horse-providers](file:///d:/delphi/horse/doc/skills/horse-providers.md)**: Escolha de adaptadores (Indy, Daemon, HTTP.sys, ISAPI).
*   **[horse-writing-middleware](file:///d:/delphi/horse/doc/skills/horse-writing-middleware.md)**: Manual de assinaturas e callbacks para middlewares customizados.
