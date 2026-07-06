# Manual de Refatoração de Código Legado no Delphi

Este manual descreve as estratégias e padrões arquiteturais para desacoplar interfaces visuais (VCL/FMX) antigas, implementar o padrão Humble Object e lidar com migração Unicode em bases de código legadas.

---

## 1. Padrão Humble Object (Desacoplamento de UI)
Em projetos legados do Delphi, é muito comum encontrar regras de negócio complexas, queries de banco de dados e controle de transações declarados diretamente em eventos de componentes visuais (como o `OnClick` de um botão em um `TForm`). 

O padrão **Humble Object** consiste em extrair toda essa lógica lógica de negócio e queries para uma classe pura ("humilde" ou de serviço), deixando na tela visual apenas o código mínimo para coletar dados da UI e repassá-los para o serviço de execução.

### Exemplo Prático de Refatoração (Humble Object)

#### Código Legado Incorreto (Acoplado no Form):
```delphi
procedure TFormCustomer.BtnSaveClick(Sender: TObject);
begin
  // Violação: Lógica de banco e validação acopladas no formulário visual
  if EdtName.Text = '' then
    raise Exception.Create('Nome obrigatorio.');
    
  FDQuery1.SQL.Text := 'INSERT INTO CUSTOMER(NAME) VALUES(:NAME)';
  FDQuery1.ParamByName('NAME').AsString := EdtName.Text;
  FDQuery1.ExecSQL;
  
  ShowMessage('Cliente salvo com sucesso.');
end;
```

#### Código Refatorado Correto (Humble Object):
1. **A Classe de Serviço Pura (`Service.Customer.pas`)**:
```delphi
unit Service.Customer;

interface

uses
  FireDAC.Comp.Client;

type
  TCustomerService = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    procedure SaveCustomer(const AName: string);
  end;

implementation

constructor TCustomerService.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

procedure TCustomerService.SaveCustomer(const AName: string);
begin
  // Validação Fail-Fast
  if AName.Trim.IsEmpty then
    raise Exception.Create('Nome obrigatorio.');

  var LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'INSERT INTO CUSTOMER(NAME) VALUES(:NAME)';
    LQuery.ParamByName('NAME').AsString := AName;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.
```

2. **O Evento do Form Visual Simplificado (Humble Object)**:
```delphi
procedure TFormCustomer.BtnSaveClick(Sender: TObject);
begin
  // O Form agora é "humilde": coleta os dados da UI e delega a execução
  var LService := TCustomerService.Create(DMConnection.FDConnection1);
  try
    LService.SaveCustomer(EdtName.Text);
    ShowMessage('Cliente salvo com sucesso.');
  finally
    LService.Free;
  end;
end;
```

---

## 2. Refatoração Incremental e Segura
*   **Não reescreva tudo do zero**: Substituições em massa de sistemas legados de grande porte costumam falhar. Aplique a "Regra do Escoteiro": deixe o código um pouco mais limpo do que como você o encontrou em cada tarefa de desenvolvimento.
*   **Encapsule Classes Antigas**: Se precisar interagir com um módulo legado complexo que não pode ser refatorado de imediato, crie uma classe de serviço intermediária (padrão *Adapter* ou *Wrapper*) para isolar o sistema moderno do código legado.

---

## 3. Cuidados na Migração Unicode
A partir do Delphi 2009, o tipo `string` padrão passou a representar strings Unicode (`WideString` ou UTF-16). Ao migrar códigos muito antigos (Delphi 7 ou anterior):

*   **Tamanho em Bytes (SizeOf)**: Nunca use `SizeOf(Char)` assumindo que é 1 byte. Em Unicode, `SizeOf(Char)` é de **2 bytes**. Se precisar alocar buffers de bytes para chamadas de sistema, use o tipo `AnsiChar` de forma explícita.
*   **Conversões de Arquivos**: Ao ler ou gravar arquivos texto legados em disco, configure explicitamente a codificação UTF-8 ou ANSI correspondente usando a classe `TEncoding`:
    ```delphi
    LStrings.SaveToFile('arquivo.txt', TEncoding.UTF8);
    ```
