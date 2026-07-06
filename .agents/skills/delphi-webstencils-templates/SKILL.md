---
name: delphi-webstencils-templates
description: Diretrizes de qualidade e desenvolvimento de templates HTML e páginas dinâmicas com Web Stencils (Server-Side Rendering) no Delphi.
---

# Diretrizes para Desenvolvimento com Web Stencils no Delphi

Esta skill define o guia de boas práticas, a sintaxe de template e a arquitetura de servidor para o desenvolvimento de aplicações web dinâmicas utilizando o recurso **Web Stencils** (Server-Side Rendering) nativo do Delphi (introduzido no RAD Studio 12.2 Athens e posterior).

---

## 1. Arquitetura no Servidor (Delphi)

O processamento do Web Stencils apoia-se em dois componentes principais no lado do servidor, geralmente declarados em um `TWebModule`:
*   **`TWebStencilsEngine`**: Componente central responsável por gerenciar caminhos físicos, mapeamento de URLs para arquivos HTML físicos e gerenciamento do contexto de processamento.
*   **`TWebStencilsProcessor`**: Componente que realiza o processamento real de um template HTML individual, fazendo a associação de variáveis e objetos.

### Registro de Variáveis e Datasets (AddVar)
Para disponibilizar objetos, records ou Datasets para serem interpretados no template HTML, registre-os explicitamente no processador ou na engine utilizando o método `AddVar`:

```delphi
procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest; 
  Response: TWebResponse; var Handled: Boolean);
begin
  // Abrir o Dataset antes de processar o template
  qryProducts.Open;

  // Registrar o dataset com o nome de variável que será usado no HTML
  if not WebStencilsProcessor1.HasVar('Products') then
    WebStencilsProcessor1.AddVar('Products', qryProducts, False);

  // Atribuir o HTML processado como conteúdo de resposta
  Response.Content := WebStencilsProcessor1.Content;

  // Fechar o Dataset após a renderização
  qryProducts.Close;
end;
```
*Nota: Ao utilizar o terceiro parâmetro de `AddVar` como `False` (AOwnsObject), você instrui o motor a não destruir o objeto associado ao término da execução.*

### Resolução Dinâmica (OnValue)
Para valores calculados tardiamente ou variáveis contextuais de requisição (como nomes de usuário logados), utilize o evento `OnValue` do `TWebStencilsProcessor`:

```delphi
procedure TWebModule1.WebStencilsProcessor1GetValue(Sender: TObject; 
  const VarName: string; var Value: TValue; var Handled: Boolean);
begin
  if VarName.Equals('CurrentYear') then
  begin
    Value := FormatDateTime('yyyy', Now);
    Handled := True;
  end;
end;
```

---

## 2. Sintaxe de Templates (HTML)

Web Stencils utiliza a marcação `@` para transicionar de marcação estática HTML para código dinâmico gerado pelo Delphi.

### Exibição de Variáveis e Campos
Para exibir valores de variáveis ou propriedades de objetos registrados:
*   Variáveis Simples: `@VarName`
*   Campos de Objetos/Datasets: `@Products.Name` ou `@Customer.Address.City`

### Estruturas Condicionais (@if)
Permite renderizar blocos HTML baseados em expressões booleanas:
```html
@if(user.isLoggedIn) {
  <div class="user-profile">
    <p>Bem-vindo de volta, @user.name!</p>
  </div>
}
@if(!user.isLoggedIn) {
  <a href="/login" class="btn btn-primary">Fazer Login</a>
}
```

### Iteração em Datasets (@foreach)
Para exibir listagens, tabelas e repetições a partir de um `TDataSet` registrado, use a instrução `@foreach`:
```html
<table class="table">
  <thead>
    <tr>
      <th>Código</th>
      <th>Produto</th>
      <th>Preço</th>
    </tr>
  </thead>
  <tbody>
    @foreach Products {
      <tr>
        <td>@loop.Id</td>
        <td>@loop.Description</td>
        <td>R$ @loop.Price</td>
      </tr>
    }
  </tbody>
</table>
```
*Regra Crítica: No escopo interno do bloco `@foreach`, utilize sempre o marcador especial `@loop.<Nome_Do_Campo>` para referenciar as colunas da linha atual do cursor.*

### Escapando o Símbolo @ (Escape)
Caso o arquivo HTML precise renderizar um caractere `@` literal (como em endereços de e-mail ou scripts externos), escape-o utilizando `@` duplo:
```html
<p>Entre em contato pelo e-mail: suporte@@empresa.com</p>
```

---

## 3. Herança de Layouts (Layout Pages)

Para evitar duplicação de estruturas de página comuns (como cabeçalhos, rodapés e menus), utilize o sistema de herança:

### 1. Definindo a Master Page (`_layout.html`)
Crie a estrutura global do site e insira o marcador `@RenderBody` onde a página filha será injetada:
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <title>Meu WebApp Delphi</title>
  <link rel="stylesheet" href="/css/site.css">
</head>
<body>
  <header>...</header>
  
  <main class="container">
    @RenderBody
  </main>
  
  <footer>...</footer>
</body>
</html>
```

### 2. Definindo a Página Filha (`index.html`)
Na primeira linha do arquivo filho, utilize o marcador `@LayoutPage` apontando para o arquivo master correspondente:
```html
@LayoutPage _layout.html

<section class="hero">
  <h1>Página Inicial</h1>
  <p>Esta seção será injetada no local correspondente ao RenderBody da Master Page.</p>
</section>
```

---

## 4. Integração com Frontend Moderno (HTMX)
O Web Stencils é o par perfeito para o **HTMX**. Como as requisições AJAX do HTMX exigem fragments parciais de HTML renderizados pelo servidor, use o `TWebStencilsProcessor` para retornar apenas o trecho HTML necessário em respostas dinâmicas:

```html
<!-- Exemplo HTMX que recarrega um fragmento dinâmico renderizado pelo Delphi -->
<button hx-get="/api/products/list" hx-target="#product-table" class="btn">
  Atualizar Tabela
</button>
```
No backend, processe um template HTML parcial que renderiza apenas o bloco da tabela `@foreach` e devolva a string gerada para o cliente.
