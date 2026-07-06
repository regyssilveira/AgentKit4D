# Manual de TDD e Qualidade de Código no Delphi

Este manual apresenta as diretrizes para adoção do Desenvolvimento Orientado a Testes (TDD), escrita de testes robustos com o framework DUnitX e correções de bugs orientadas a testes de regressão.

---

## 1. O Ciclo de TDD (Red-Green-Refactor)
Ao desenvolver novas rotinas, implemente a mentalidade TDD seguindo estes três passos sequenciais:

1.  **Red (Vermelho)**: Escreva primeiro a assinatura da interface e a unit de teste correspondente. Execute os testes e certifique-se de que o novo teste falhe (uma falha esperada, pois o código de negócio ainda não existe).
2.  **Green (Verde)**: Escreva o código de produção mínimo necessário para que o teste passe com sucesso.
3.  **Refactor (Refatorar)**: Melhore a qualidade do código produzido (nomenclatura, remoção de duplicações, performance) garantindo que os testes continuem passando (verde).

---

## 2. Estrutura de Testes com DUnitX
O **DUnitX** é o framework moderno oficial integrado ao Delphi para testes unitários.

### Estrutura de uma Unit de Teste
```delphi
unit Service.User.Tests;

interface

uses
  DUnitX.TestFramework,
  Service.User;

type
  [TestFixture]
  TUserServiceTests = class
  private
    FService: TUserService;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    
    [Test]
    procedure Test_CalculateDiscount_ShouldApplyCorrectPercent;
  end;

implementation

procedure TUserServiceTests.Setup;
begin
  FService := TUserService.Create;
end;

procedure TUserServiceTests.TearDown;
begin
  FService.Free;
end;

procedure TUserServiceTests.Test_CalculateDiscount_ShouldApplyCorrectPercent;
begin
  var LDiscount := FService.CalculateDiscount(100);
  Assert.AreEqual(10.0, LDiscount, 0.001, 'O desconto deve ser de 10%');
end;

initialization
  TDUnitX.RegisterTestFixture(TUserServiceTests);
end.
```

---

## 3. Correção de Bugs Baseada em Testes (Regressão)
Ao identificar um bug em produção, utilize o seguinte fluxo para corrigi-lo:

1.  **Reproduza com um Teste**: Antes de alterar o código de produção, escreva um teste unitário que reproduza exatamente o cenário de erro reportado. O teste deve rodar e falhar (Red).
2.  **Corrija o Código**: Implemente o ajuste na unit de produção correspondente para sanar a falha.
3.  **Valide a Correção**: Execute novamente a suíte de testes. A suíte inteira deve passar (Green), provando que o bug foi sanado e que nenhuma funcionalidade existente foi corrompida (regressão).

---

## 4. Melhores Práticas para Escrita de Testes
*   **Isolamento Completo**: Cada teste deve ser independente. Nunca compartilhe estado entre testes (limpe variáveis nos métodos de `Setup` e `TearDown`).
*   **Não Teste Bancos de Dados Reais**: Use dublês de teste (Mocks ou Stubs) para isolar chamadas a banco de dados ou APIs de terceiros. Testes unitários devem rodar inteiramente em memória e de forma extremamente rápida.
*   **Nomeação Clara**: Os nomes dos métodos de teste devem descrever a ação e o resultado esperado (padrão: `Test_Acao_DeveResultado`).
