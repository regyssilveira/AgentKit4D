# Manual de Web Stencils no Delphi

Este manual apresenta as diretrizes de desenvolvimento, sintaxe de template e padrões arquiteturais para a criação de páginas dinâmicas e layouts utilizando o motor de renderização server-side **Web Stencils** (Server-Side Rendering) no Delphi.

---

## 1. Arquitetura no Servidor (Delphi)
O Web Stencils é projetado para integrar a geração de HTML no servidor de forma modular com tecnologias como WebBroker ou RAD Server.

*   **Configuração de Variáveis (AddVar)**: Sempre registre explicitamente os datasets ou objetos que serão consumidos pelo template HTML. O dataset correspondente deve ser aberto antes do processamento e fechado após o término da renderização:

```delphi
procedure TWebModule1.RenderPage(Response: TWebResponse);
begin
  qryCustomers.Open;
  try
    // Registrar o Dataset para ser lido no HTML
    WebStencilsProcessor1.AddVar('Customers', qryCustomers, False);
    Response.Content := WebStencilsProcessor1.Content;
  finally
    qryCustomers.Close;
  end;
end;
```

*   **Evento OnValue**: Use o evento `OnValue` do `TWebStencilsProcessor` para injetar valores calculados dinamicamente no HTML sem a necessidade de instanciar objetos adicionais.

---

## 2. Sintaxe de Templates (HTML)
A sintaxe utiliza a marcação `@` para transicionar do HTML estático para dados e instruções dinâmicas interpretadas pelo motor Delphi.

*   **Valores de Campos**: Use `@objeto.propriedade` (ex: `@user.name`) para renderizar variáveis na página.
*   **Decisão (@if)**: Permite renderizar trechos HTML condicionais:
    ```html
    @if(user.isAdmin) {
      <button class="btn-danger">Painel Administrativo</button>
    }
    ```
*   **Iteração (@foreach)**: Usado para loops de dados baseados em `TDataSet`. No corpo do loop, acesse as colunas da linha corrente com o prefixo especial `@loop`:
    ```html
    @foreach Customers {
      <tr>
        <td>@loop.Id</td>
        <td>@loop.Name</td>
      </tr>
    }
    ```
*   **Escape de Caractere**: Caso precise renderizar um caractere `@` literal na página (ex: um e-mail), escape-o utilizando o símbolo duplicado: `suporte@@empresa.com`.

---

## 3. Herança de Layout e HTMX
*   **Layout Pages**: Use a instrução `@LayoutPage _master.html` no topo de páginas filhas e declare o marcador `@RenderBody` no arquivo master correspondente para manter cabeçalhos e rodapés centralizados.
*   **Integração HTMX**: O Web Stencils é altamente recomendado para trabalhar com o **HTMX**. Configure ações do HTMX (como `hx-get`) apontando para rotas do Delphi que renderizam apenas fragmentos dinâmicos de HTML (parciais) com o `TWebStencilsProcessor`, evitando o carregamento completo de páginas.
