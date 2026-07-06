# Manual de Integração com o Ecossistema ACBr no Delphi

Este manual descreve as diretrizes para desenvolvimento e integração estável com o ecossistema ACBr (Automação Comercial Brasil), abordando o desacoplamento de lógica fiscal, isolamento de eventos de interface e compatibilidade multiplataforma.

---

## 1. Desacoplamento da Lógica Fiscal (Wrappers)
Os componentes ACBr (como `TACBrNFe`, `TACBrNFSe`, `TACBrCTE`, etc.) gerenciam fluxos complexos de comunicação com a SEFAZ. Nunca insira chamadas diretas a propriedades de componentes ACBr ou manipulação de XMLs fiscais dentro de formulários (`TForm`) ou rotinas de telas de venda (PDV).

*   **Padrão Wrapper/Adapter**: Encapsule o componente ACBr e todas as suas configurações em uma classe de serviço ou repositório fiscal específico (Wrapper):

```delphi
type
  TFiscalNFeService = class
  private
    FACBrNFe: TACBrNFe;
    procedure ConfigurarComponente;
  public
    constructor Create;
    destructor Destroy; override;
    function EmitirNFe(const APedidoId: Integer): string; // Retorna chave da NFe emitida
  end;
```

Dessa forma, o seu botão de venda no formulário só chamará o método do Wrapper fiscal: `LFiscalService.EmitirNFe(LPedidoId)`, sem sequer saber da existência das units do ACBr na sua cláusula `uses`.

---

## 2. Desacoplamento de Eventos de UI
Componentes ACBr fazem uso intensivo de eventos (`OnStatusChange`, `OnGerarPDF`, `OnTransmit`, etc.) para reportar status ou requisitar interações.

*   **Evite Conexão Direta com a UI**: Não conecte eventos dos componentes fiscais diretamente a métodos de forms visuais (ex: `ACBrNFe1.OnStatusChange := Form1.OnStatusChange`).
*   **Encapsulamento por Delegation**: Trate os eventos internamente na classe do seu Wrapper fiscal. Se a tela visual precisar ser informada do andamento, defina callbacks simples ou utilize um sistema de eventos desacoplado (padrão *Observer* ou *Event Bus*):

```delphi
// Método interno do Wrapper tratando evento
procedure TFiscalNFeService.DoOnStatusChange(Sender: TObject);
begin
  // Notifica a UI sem acoplamento se um callback estiver registrado
  if Assigned(FOnStatusNotify) then
    FOnStatusNotify('Transmitindo lote...');
end;
```

---

## 3. Compatibilidade Multiplataforma (Configuração de DLLs)
Ao configurar emissões fiscais usando ACBr, atente-se às bibliotecas criptográficas para manter a compatibilidade multiplataforma e estabilidade na nuvem (serviços REST/Horse no Linux ou Windows):

*   **WinCrypt vs OpenSSL**:
    *   **Windows**: Utilize preferencialmente a biblioteca nativa do Windows (`WinCrypt`), que dispensa a necessidade de distribuir DLLs adicionais de OpenSSL com a sua aplicação.
    *   **Linux / Multiplataforma**: Utilize `OpenSSL` configurando as DLLs/Lib do OpenSSL em conjunto com os caminhos corretos de distribuição da aplicação.
*   **Modelos de Certificado**: Configure a propriedade `SSLLib` de acordo com o certificado utilizado (A1 ou A3):
    *   Para certificados do tipo arquivo (.pfx A1), use `libOpenSSL` ou `libWinCrypt`.
    *   Para certificados físicos (tokens A3), o uso de `libWinCrypt` é mandatório no Windows.
