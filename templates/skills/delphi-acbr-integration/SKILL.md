---
name: delphi-acbr-integration
description: Arquitetura e padrões de integração com o ecossistema ACBr (Automação Comercial Brasil) em Delphi. Desacoplamento de UI e controle fiscal.
---

# Arquitetura e Integração Fiscal com ACBr no Delphi

Esta guia define boas práticas para integrar componentes do ecossistema ACBr (NFe, NFCe, SAT, TEF, Boleto) mantendo a arquitetura limpa, testabilidade e desacoplamento visual.

## 1. Regra Fundamental: Desacoplamento Visual
> **NUNCA instancie componentes ACBr diretamente nos formulários de interface visual (`TForm` / `TFrame`).**
> O acoplamento de lógica fiscal à tela inviabiliza testes unitários e dificulta a portabilidade do projeto para cenários sem interface gráfica (ex: microserviços REST ou automações em lote).

---

## 2. Padrão Wrapper / Humble Object
Crie classes de serviços de infraestrutura (encapsulados por interfaces) para inicializar, configurar e disparar as ações dos componentes fiscais em tempo de execução:

```pascal
type
  INFeEmissor = interface
    ['{B94C6D5F-1D10-4A92-B796-03C89B10065F}']
    function EmitirNota(const ANotaFiscal: TNotaFiscalData): TEmissionResult;
  end;

  TNFeEmissorACBr = class(TInterfacedObject, INFeEmissor)
  private
    FAcbrNFe: TACBrNFe;
    FConfig: IAppConfig;
    procedure ConfigureGeral;
  public
    constructor Create(AConfig: IAppConfig);
    destructor Destroy; override;
    function EmitirNota(const ANotaFiscal: TNotaFiscalData): TEmissionResult;
  end;
```

---

## 3. Gestão Dinâmica de Bibliotecas de Criptografia (SSLLib)
Sempre configure as diretivas de criptografia e transmissão (ex: OpenSSL vs. WinCrypt) dinamicamente via código dentro da classe de serviço, adaptando-se ao sistema operacional (especialmente em cenários multi-dispositivo ou servidores Linux):

```pascal
FAcbrNFe.Configuracoes.Geral.SSLLib := libWinCrypt; // Windows
// FAcbrNFe.Configuracoes.Geral.SSLLib := libOpenSSL; // Linux / Docker
```

---

## 4. Desacoplamento de Eventos e Callbacks (Ex: TEF)
Componentes de TEF (ACBrTEFD) dependem fortemente de eventos para interagir com o operador (ex: `OnExibeMensagem`, `OnAguardaDigitacao`).
Para manter o componente isolado da camada visual:
*   Declare interfaces de callbacks de apresentação (`IPresentationHandler`) e as injete na sua classe de serviço que manipula o TEF.
*   Os eventos do componente chamam a interface, permitindo que a visualização implemente como exibir a mensagem (seja em um painel VCL, caixa de diálogo FMX ou resposta JSON em uma API).

```pascal
type
  ITefPresentation = interface
    procedure ShowMessage(const AMsg: string);
    procedure ClearScreen;
  end;
```

---

## 5. Convenções de Nomenclatura para Componentes ACBr

Ao registrar instâncias ou criar componentes em DataModules de suporte, utilize os seguintes prefixos padronizados:

| Componente ACBr | Descrição | Prefixo Recomendado | Exemplo |
| :--- | :--- | :--- | :--- |
| `TACBrNFe` | Emissão de Nota Fiscal Eletrônica | `acbrNfe` | `acbrNfeFiscal` |
| `TACBrNFCe` | Emissão de Cupom Fiscal Eletrônico | `acbrNfce` | `acbrNfceCupom` |
| `TACBrCTe` | Conhecimento de Transporte Eletrônico | `acbrCte` | `acbrCteTransp` |
| `TACBrBoleto` | Gestão e Geração de Boletos Bancários | `acbrBoleto` | `acbrBoletoCobranca` |
| `TACBrTEFD` | Integração com Transferência Eletrônica de Fundos | `acbrTef` | `acbrTefPagamento` |
| `TACBrPosPrinter` | Controle de Impressoras Não Fiscais (EscPOS) | `acbrPosPrinter` | `acbrPosPrinterTerm` |
| `TACBrSAT` | Emissão de cupons via equipamento SAT | `acbrSat` | `acbrSatCupom` |
