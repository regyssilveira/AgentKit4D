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
| **[AGENTS.md.template](file:///d:/Projetos/AgentKit4D/AGENTS.md.template)** | Diretrizes arquiteturais de Clean Code, SOLID, TDD e boas práticas específicas de Delphi estruturadas para serem consumidas e seguidas por IAs de desenvolvimento. |
| **[run_sonar.bat.template](file:///d:/Projetos/AgentKit4D/run_sonar.bat.template)** | Script em lote auxiliar que facilita a execução local da análise estática do SonarQube com gestão segura do token de acesso. |
| **[generate_coverage.ps1.template](file:///d:/Projetos/AgentKit4D/generate_coverage.ps1.template)** | Script PowerShell para calcular, normalizar e gerar o relatório XML de *Generic Coverage* para o SonarQube a partir dos testes executados. |

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

Siga os passos abaixo para implantar a qualidade de código em seu novo projeto Delphi:

### Passo 1: Configurar a Análise Estática (SonarQube)
1. Copie o arquivo [sonar-project.properties.template](file:///d:/Projetos/AgentKit4D/sonar-project.properties.template) para a **raiz** do seu novo projeto Delphi.
2. Renomeie o arquivo para: **`sonar-project.properties`**.
3. Abra o arquivo e configure os metadados iniciais do seu projeto:
   ```properties
   sonar.projectKey=MeuProjeto
   sonar.projectName=Meu Projeto
   sonar.projectVersion=1.0.0
   ```
4. Ajuste os diretórios de fontes (`sonar.sources`) e testes (`sonar.tests`) no arquivo de propriedades caso as pastas do seu projeto não sigam os diretórios padrão `src` e `tests`.

### Passo 2: Configurar o Agent de IA (Antigravity e outros)
Para garantir que as IAs sigam o mesmo padrão de código do repositório:
1. Na **raiz** do seu novo projeto, crie um diretório chamado: **`.agents`**.
2. Copie o arquivo [AGENTS.md.template](file:///d:/Projetos/AgentKit4D/AGENTS.md.template) para dentro dessa pasta.
3. Renomeie o arquivo para: **`AGENTS.md`**.
4. Qualquer assistente de IA que interagir com o seu repositório passará a ler e seguir de forma automática as diretrizes DelphiSonar documentadas nele.

### Passo 3: Executar a Análise Local com Cobertura
1. Crie uma pasta chamada **`scripts`** (ou `scratch`) na raiz do seu projeto.
2. Copie o arquivo [generate_coverage.ps1.template](file:///d:/Projetos/AgentKit4D/generate_coverage.ps1.template) para dentro dela e renomeie-o para **`generate_coverage.ps1`**.
3. Execute o script via PowerShell para mapear as linhas executáveis do seu projeto e gerar o relatório XML estruturado.
4. Copie o arquivo [run_sonar.bat.template](file:///d:/Projetos/AgentKit4D/run_sonar.bat.template) para a **raiz** do seu projeto e renomeie-o para **`run_sonar.bat`**.
5. Execute o script `run_sonar.bat`. O script gerencia o token de acesso automaticamente através do seguinte fluxo de prioridade:
   * **Variável de Ambiente**: Se a variável `%SONAR_TOKEN%` estiver definida no terminal ou no Windows, ela será usada de imediato.
   * **Arquivo Local**: Se a variável de ambiente estiver ausente, ele tentará ler do arquivo local `sonar_token.txt` criado na raiz.
   * **Entrada Manual (Interativa)**: Se nenhuma das opções anteriores estiver configurada, ele solicitará o token no console e oferecerá a opção de gravá-lo no arquivo local `sonar_token.txt` para automatizar execuções futuras.

> [!IMPORTANT]
> **Adicione o arquivo `sonar_token.txt` ao seu `.gitignore`!**
> É fundamental garantir que este arquivo com credenciais locais nunca seja comitado para repositórios públicos.

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
