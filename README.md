# Delphi Agent Quality Kit (AgentKit4D)

Uma solução completa contendo diretrizes, automações e modelos de configuração para estabelecer um pipeline de qualidade de código estrito e alinhado aos padrões do **SonarQube (DelphiSonar / DelphiLint)** em projetos Delphi.

Este kit foi projetado para unificar os padrões de desenvolvimento entre desenvolvedores humanos e **agentes de IA (coding assistants)**, garantindo conformidade com Clean Code, SOLID, e gestão de memória.

---

## 🎯 O que é este projeto?

A adoção de análises estáticas robustas no ecossistema Delphi frequentemente esbarra em desafios como:
*   **Falsos positivos frequentes**: Parsers de ferramentas analíticas geram alertas incorretos para novos recursos da linguagem, como declarações de variáveis inline ou regras de localização de imports no `uses` (`ImportSpecificity`).
*   **Gestão de Cobertura**: A compilação e mapeamento de testes unitários para a geração de relatórios de cobertura em formato compatível com o SonarQube exigem scripts de normalização customizados.
*   **Falta de contexto para IAs**: Agentes de IA precisam de guias específicos da linguagem e do projeto para evitar a sugestão de construções obsoletas, arcaicas ou propensas a vazamentos de memória (*memory leaks*).

O **Delphi Agent Quality Kit** mitiga esses problemas oferecendo modelos pré-configurados e scripts automatizados de apoio. Ao implantar este kit em um novo repositório, você estabelece de forma imediata um ambiente de desenvolvimento padronizado, automatizado e livre de ruídos na análise estática.

---

## 📦 Estrutura do Kit (Componentes)

| Componente | Descrição |
| :--- | :--- |
| **[sonar-project.properties.template](file:///d:/Projetos/AgentKit4D/sonar-project.properties.template)** | Modelo pronto contendo configurações otimizadas para o SonarQube, supressão de falsos positivos do parser Delphi (variáveis inline/imports) e regras de exclusão de duplicações (CPD) para stubs e telas visuais (`.dfm`). |
| **[AGENTS.md](file:///d:/Projetos/AgentKit4D/.agents/AGENTS.md)** | Diretrizes arquiteturais de Clean Code, SOLID, TDD e boas práticas específicas de Delphi estruturadas para serem consumidas e seguidas por IAs de desenvolvimento. |
| **[run_sonar.bat.template](file:///d:/Projetos/AgentKit4D/run_sonar.bat.template)** | Script em lote auxiliar que facilita a execução local da análise estática do SonarQube com gestão segura do token de acesso. |
| **[generate_coverage.ps1](file:///d:/Projetos/AgentKit4D/scripts/generate_coverage.ps1)** | Script PowerShell para calcular, normalizar e gerar o relatório XML de *Generic Coverage* para o SonarQube a partir dos testes executados. |

---

## 🔌 Habilitando Suporte a Delphi no SonarQube (Pré-requisitos)

Antes de rodar as análises em seus projetos, o seu servidor SonarQube precisa saber interpretar o código Delphi (`.pas`). Caso ainda não possua o plugin instalado, siga uma das opções abaixo:

### Opção 1: Instalação via SonarQube Marketplace (Recomendado)
1. Acesse o painel do seu SonarQube como administrador.
2. Navegue até: **Administration > Marketplace**.
3. Procure por: **Delphi** (como o plugin comunitário *Sonar-Delphi* ou *DelphiSonar*).
4. Clique em **Install** e reinicie o servidor SonarQube conforme solicitado.

### Opção 2: Instalação Manual (Servidores Offline)
Se o seu servidor SonarQube não possuir acesso à internet:
1. Baixe o arquivo `.jar` estável do plugin de Delphi compatível com sua versão do SonarQube a partir de repositórios oficiais da comunidade (ex: [Sonar-Delphi](https://github.com/checkstyle/sonar-delphi)).
2. Copie o arquivo `.jar` para o diretório de plugins do seu servidor:
   ```bash
   /caminho/do/seu/sonarqube/extensions/plugins/
   ```
3. Reinicie o servidor do SonarQube.

> [!TIP]
> **DelphiLint e Relatórios Externos**: Caso utilize analisadores adicionais locais (como o *DelphiLint*), você pode configurá-los para exportar um relatório de issues e passá-lo para a análise do SonarQube adicionando a propriedade `sonar.externalIssuesReportPaths` no seu arquivo `sonar-project.properties`.

---

## 🔌 Integração Automática via Plugin de IDE (Recomendado)

O **AgentKitPlugin** é um pacote design-time que se instala diretamente na IDE do RAD Studio (compatível com as versões **Delphi 11 Alexandria, Delphi 12 Athens e Delphi 13**). Ele automatiza completamente todos os passos manuais de configuração de qualidade em novos projetos.

### O que o plugin faz?
* **Interface Visual VCL**: Apresenta uma janela interativa para preenchimento rápido de metadados do projeto (sugerindo Project Key/Name automaticamente).
* **Criação Automática no SonarQube**: Integra-se com a API do servidor SonarQube para criar o projeto diretamente na rede de forma integrada.
* **Download Dinâmico com Fallback Offline**: Tenta baixar as versões mais estáveis dos templates diretamente deste repositório público no GitHub. Caso a conexão falhe, utiliza cópias internas dos templates embutidos nativamente no plugin.
* **Log Integrado na IDE**: Exibe todo o progresso de download e escrita de arquivos diretamente no painel oficial de **"Messages"** (aba dedicada "AgentKit") da IDE.
* **Não Bloqueante**: A comunicação de rede é executada assincronamente em segundo plano, evitando travamentos na IDE do Delphi.

### Como Instalar o Plugin no Delphi:
1. Abra o projeto de pacote **[AgentKitPlugin.dproj](file:///d:/Projetos/AgentKit4D/plugin/AgentKitPlugin.dproj)** no seu RAD Studio.
2. Na janela do Project Manager da IDE, selecione o target platform **Win32** (plataforma padrão do executável da IDE `bds.exe`).
3. Clique com o botão direito no projeto `AgentKitPlugin.bpl` e selecione **Build** (para compilar os fontes e embutir os recursos `.rc`).
4. Clique com o botão direito novamente e selecione **Install**.
5. Um aviso confirmará o registro do plugin na IDE.

### Como Utilizar:
* **Delphi 12 e 13**: Clique com o **botão direito** sobre o projeto ativo no **Project Manager** da IDE e escolha **"AgentKit: Initialize Quality Kit"**.
* **Delphi 11**: Acesse a opção **"AgentKit: Initialize Quality Kit"** inserida sob o menu **Tools** (Ferramentas) superior da IDE.

---

## 🛠️ Como Utilizar em um Novo Projeto

Escolha uma das trilhas abaixo para implantar o Delphi Agent Quality Kit em seu novo projeto:

### Trilha A: Inicialização Automática via Plugin (Recomendado)
Se você instalou o **AgentKitPlugin** na IDE do Delphi:
1. Abra o seu projeto no RAD Studio.
2. Clique com o **botão direito** sobre o projeto ativo no **Project Manager** (ou no menu **Tools** superior) e escolha **"AgentKit: Initialize Quality Kit"**.
3. Preencha os metadados do projeto na tela visual (Project Key, Name, Versão e URL do SonarQube).
4. O plugin criará toda a estrutura de pastas (`.agents/`, `.agents/skills/` e `scripts/`), além dos arquivos de propriedades, scripts e a exclusão do token no `.gitignore` de forma 100% automatizada.

### Trilha B: Inicialização Manual (Sem Plugin / Cópia Direta)
Se prefere não utilizar o plugin e configurar o projeto manualmente, o processo é extremamente simples por conta da estrutura viva do kit:

1. **Copiar Diretórios**:
   * Copie a pasta **`[.agents/](file:///d:/Projetos/AgentKit4D/.agents)`** inteira da raiz do kit para a raiz do seu projeto. (Pronto! Suas regras globais e as 11 skills já estão instaladas no lugar correto).
   * Copie a pasta **`[scripts/](file:///d:/Projetos/AgentKit4D/scripts)`** inteira da raiz do kit para a raiz do seu projeto (ela contém o script `generate_coverage.ps1`).

2. **Copiar e Renomear Arquivos de Configuração**:
   * Copie o arquivo **`[sonar-project.properties.template](file:///d:/Projetos/AgentKit4D/sonar-project.properties.template)`** para a raiz do seu projeto e renomeie-o para **`sonar-project.properties`** (ajustando os metadados como Key e Name do seu projeto).
   * Copie o arquivo **`[run_sonar.bat.template](file:///d:/Projetos/AgentKit4D/run_sonar.bat.template)`** para a raiz do seu projeto e renomeie-o para **`run_sonar.bat`**.

3. **Definir o Token e GitIgnore**:
   * Caso queira usar o script `run_sonar.bat` localmente sem precisar digitar o token do SonarQube toda vez, crie um arquivo **`sonar_token.txt`** na raiz do seu projeto e cole o token dele.
   * **IMPORTANTE**: Certifique-se de adicionar a linha `sonar_token.txt` no `.gitignore` do seu projeto para evitar vazamentos acidentais de credenciais.

---

## 🌟 Benefícios e Boas Práticas Integradas
*   **Ciclo de TDD Blindado**: Padrões estabelecidos para correção orientada a testes (*TDD para bugs*) e desenvolvimento de novas funcionalidades.
*   **Gerenciamento Inteligente de Falsos Positivos**: Silencia alertas desnecessários de estilo e formatação ao focar no que realmente importa para a segurança do software.
*   **Gestão Anti-Vazamento**: Padronização de destruidores (`override`), construtores (`inherited`) e uso de `try..finally` e `FreeAndNil` de forma limpa.
*   **Compilação Win32 e Win64**: Dicas e contornos práticos para evitar falhas clássicas de compiladores, como inferências incorretas do DUnitX em 64 bits e encerramento indesejado de scripts `.bat` sequenciais.

---

## 🤖 Engenharia de Prompt e Interação com IAs

> [!NOTE]
> **Leitura Automática**: Coding assistants modernos integrados ao ambiente/IDE (como o Antigravity) detectam e consomem as regras do arquivo `.agents/AGENTS.md` de forma **100% automática** a partir do contexto do projeto. As instruções manuais e prompts a seguir são recomendados apenas para guiar o foco da IA em tarefas específicas ou ao interagir com interfaces de chat externas baseadas na web (sem indexação física do repositório).

Para tirar o máximo proveito do arquivo `AGENTS.md` ao trabalhar com coding assistants modernos (como Antigravity, Cursor, GitHub Copilot ou Claude), você pode estruturar seus prompts para que eles leiam e apliquem as diretrizes ativamente.

### Como referenciar nas ferramentas de IA
*   **Cursor / VS Code (AI Chat)**: Digite `@AGENTS.md` (ou adicione o arquivo como contexto) e faça o seu pedido.
*   **GitHub Copilot / Chat**: Utilize `#file:AGENTS.md` na caixa de diálogo.
*   **Custom Instructions / System Prompts**: Você pode copiar o conteúdo do arquivo para as configurações permanentes de prompt de sistema da sua IA de uso diário.

### Exemplos Práticos de Prompts

#### 1. Escrevendo nova lógica (com foco em TDD e Clean Code)
> "Leia o arquivo `.agents/AGENTS.md`. Preciso implementar uma classe de serviço em Delphi para integração com o gateway de pagamento. Crie a interface e os testes unitários do DUnitX primeiro (TDD), e siga as regras de nomenclatura e liberação de memória em blocos try..finally."

#### 2. Refatorando código legado (Humble Object)
> "Consulte as diretrizes de código legado na Seção 6 do `.agents/AGENTS.md`. Analise a unit do Form legado que anexei e ajude-me a extrair toda a lógica de negócio e queries de banco do evento Click do botão para uma classe de serviço pura, aplicando o padrão Humble Object."

#### 3. Planejamento de novas rotinas (Contract-First)
> "Aplique as diretrizes da Seção 7 (Contract-First) do `.agents/AGENTS.md`. Vamos planejar uma nova funcionalidade de importação de arquivos XML. Proponha primeiro as interfaces de abstração e as validações prematuras (Fail-Fast) antes de iniciarmos qualquer código de execução."
