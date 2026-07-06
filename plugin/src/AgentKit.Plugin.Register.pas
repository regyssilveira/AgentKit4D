unit AgentKit.Plugin.Register;

interface

uses
  System.Classes, System.SysUtils, ToolsAPI, Vcl.Menus;

procedure Register;

implementation

uses
  Winapi.Windows, Vcl.Forms, Vcl.Dialogs, Vcl.Controls, System.IOUtils, System.Threading,
  AgentKit.Common.Interfaces,
  AgentKit.Net.Client,
  AgentKit.Service.Init,
  AgentKit.Plugin.Dialog;

type
  TAgentKitProjectHelper = class
  public
    class function SanitiseProjectKey(const AName: string): string;
    class function GetActiveProject: IOTAProject;
    class procedure LogToIDE(const AMsg: string);
    class procedure ExecuteInit(const Project: IOTAProject);
  end;

  // Handler para cliques no menu do Delphi 11
  TAgentKitMenuHandler = class
  public
    class procedure MenuItemClick(Sender: TObject);
  end;

  {$IF CompilerVersion >= 36.0}
  // Implementação correta da Open Tools API de menu do Project Manager (Delphi 12/13)
  TAgentKitProjectManagerMenu = class(TNotifierObject, IOTAProjectManagerMenu, IOTALocalMenu)
  private
    FProject: IOTAProject;
    FCaption: string;
    FChecked: Boolean;
    FEnabled: Boolean;
    FHelpContext: Integer;
    FName: string;
    FParent: string;
    FPosition: Integer;
    FVerb: string;
    FIsMultiSelectable: Boolean;
  protected
    // IOTALocalMenu
    function GetCaption: string;
    function GetChecked: Boolean;
    function GetEnabled: Boolean;
    function GetHelpContext: Integer;
    function GetName: string;
    function GetParent: string;
    function GetPosition: Integer;
    function GetVerb: string;
    procedure SetCaption(const Value: string);
    procedure SetChecked(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetHelpContext(Value: Integer);
    procedure SetName(const Value: string);
    procedure SetParent(const Value: string);
    procedure SetPosition(Value: Integer);
    procedure SetVerb(const Value: string);

    // IOTAProjectManagerMenu
    function GetIsMultiSelectable: Boolean;
    procedure SetIsMultiSelectable(Value: Boolean);
    procedure Execute(const MenuContextList: IInterfaceList); overload;
    function PreExecute(const MenuContextList: IInterfaceList): Boolean;
    function PostExecute(const MenuContextList: IInterfaceList): Boolean;
  public
    constructor Create(const AProject: IOTAProject);
  end;

  TAgentKitProjectMenuItemCreatorNotifier = class(TNotifierObject, IOTAProjectMenuItemCreatorNotifier)
  protected
    procedure AddMenu(const Project: IOTAProject; const IdentList: TStrings;
      const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
  end;
  {$ENDIF}

{ TAgentKitProjectHelper }

class function TAgentKitProjectHelper.SanitiseProjectKey(const AName: string): string;
var
  c: Char;
  LBuilder: TStringBuilder;
begin
  LBuilder := TStringBuilder.Create;
  try
    for c in AName do
    begin
      if CharInSet(c, ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
        LBuilder.Append(c);
    end;
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function TAgentKitProjectHelper.GetActiveProject: IOTAProject;
var
  LModuleServices: IOTAModuleServices;
  LModule: IOTAModule;
  LProject: IOTAProject;
  i: Integer;
begin
  Result := nil;
  if Supports(BorlandIDEServices, IOTAModuleServices, LModuleServices) then
  begin
    for i := 0 to LModuleServices.ModuleCount - 1 do
    begin
      LModule := LModuleServices.Modules[i];
      if Supports(LModule, IOTAProject, LProject) then
      begin
        Result := LProject;
        Exit;
      end;
    end;
  end;
end;

class procedure TAgentKitProjectHelper.LogToIDE(const AMsg: string);
var
  LQueueProc: TThreadProcedure;
begin
  LQueueProc := procedure
    var
      LMsgServices: IOTAMessageServices;
      LGroup: IOTAMessageGroup;
    begin
      if Supports(BorlandIDEServices, IOTAMessageServices, LMsgServices) then
      begin
        LGroup := LMsgServices.AddMessageGroup('AgentKit');
        LMsgServices.AddTitleMessage(AMsg, LGroup);
      end;
    end;
  TThread.Queue(nil, LQueueProc);
end;

class procedure TAgentKitProjectHelper.ExecuteInit(const Project: IOTAProject);
var
  LProjFile: string;
  LProjDir: string;
  LProjName: string;
  LDialog: TAgentKitDialog;
  LConfig: TProjectInitConfig;
  LTaskProc: TProc;
begin
  if not Assigned(Project) then
  begin
    Application.MessageBox(
      'Nenhum projeto ativo encontrado. Abra um projeto antes de prosseguir.',
      'AgentKit',
      MB_OK or MB_ICONWARNING
    );
    Exit;
  end;

  LProjFile := Project.FileName;
  if LProjFile.IsEmpty or SameText(ExtractFileName(LProjFile), 'Untitled') then
  begin
    Application.MessageBox(
      'Por favor, salve o projeto em disco antes de inicializar o AgentKit4D.',
      'AgentKit',
      MB_OK or MB_ICONWARNING
    );
    Exit;
  end;

  LProjDir := ExtractFilePath(LProjFile);
  LProjName := ChangeFileExt(ExtractFileName(LProjFile), '');

  LDialog := TAgentKitDialog.Create(nil);
  try
    LConfig.ConfigureSonar := True;
    LConfig.CreateProjectOnServer := True;
    LConfig.ProjectKey := SanitiseProjectKey(LProjName);
    LConfig.ProjectName := LProjName;
    LConfig.ProjectVersion := '1.0.0';
    LConfig.SonarServerUrl := 'http://localhost:9000';
    LConfig.SonarToken := '';
    LConfig.ProjectPath := LProjDir;

    LDialog.Config := LConfig;

    if LDialog.ShowModal = mrOk then
    begin
      LConfig := LDialog.Config;
      LConfig.ProjectPath := LProjDir;

      // Limpa o grupo de mensagens na thread principal antes de disparar o Task de background
      var LMsgServices: IOTAMessageServices;
      var LGroup: IOTAMessageGroup;
      if Supports(BorlandIDEServices, IOTAMessageServices, LMsgServices) then
      begin
        LGroup := LMsgServices.AddMessageGroup('AgentKit');
        LMsgServices.ClearMessageGroup(LGroup);
      end;

      LTaskProc := procedure
        var
          LNetClient: IAgentKitNetClient;
          LFileSystem: IAgentKitFileSystem;
          LService: IAgentKitInitService;
          LWarnings: string;
          LSuccess: Boolean;
          LQueueShowMsg: TThreadProcedure;
        begin
          LogToIDE('--- [AgentKit] Iniciando Processo de Inicialização ---');

          LNetClient := TAgentKitNetClient.Create;
          LFileSystem := TAgentKitRealFileSystem.Create;
          LService := TAgentKitInitService.Create(
            LNetClient,
            LFileSystem,
            procedure(const AMsg: string)
            begin
              LogToIDE(AMsg);
            end
          );

          try
            LSuccess := LService.InitializeProject(LConfig, LWarnings);
            
            if LSuccess then
            begin
              LogToIDE('--- [AgentKit] Processo Concluído com Sucesso! ---');
              if not LWarnings.IsEmpty then
              begin
                LogToIDE('--- [AgentKit] Avisos Encontrados: ---');
                LogToIDE(LWarnings);
              end;
              
              LQueueShowMsg := procedure
                begin
                  Application.MessageBox(
                    'Projeto inicializado com sucesso!',
                    'AgentKit',
                    MB_OK or MB_ICONINFORMATION
                  );
                end;
              TThread.Queue(nil, LQueueShowMsg);
            end
            else
            begin
              LogToIDE('--- [AgentKit] Falha ao inicializar o projeto. ---');
            end;
          except
            on E: Exception do
            begin
              LogToIDE('[ERRO CRÍTICO] ' + E.Message);
              
              LQueueShowMsg := procedure
                begin
                  Application.MessageBox(
                    PChar('Erro ao inicializar: ' + E.Message),
                    'AgentKit',
                    MB_OK or MB_ICONERROR
                  );
                end;
              TThread.Queue(nil, LQueueShowMsg);
            end;
          end;
        end;
      
      TTask.Run(LTaskProc);
    end;
  finally
    LDialog.Free;
  end;
end;

{ TAgentKitMenuHandler }

class procedure TAgentKitMenuHandler.MenuItemClick(Sender: TObject);
begin
  TAgentKitProjectHelper.ExecuteInit(TAgentKitProjectHelper.GetActiveProject);
end;

{$IF CompilerVersion >= 36.0}
{ TAgentKitProjectManagerMenu }

constructor TAgentKitProjectManagerMenu.Create(const AProject: IOTAProject);
begin
  inherited Create;
  FProject := AProject;
  FCaption := 'AgentKit: Initialize Quality Kit';
  FChecked := False;
  FEnabled := True;
  FHelpContext := 0;
  FName := 'mnuAgentKitInitQuality';
  FParent := '';
  FPosition := 50;
  FVerb := 'InitializeQuality';
  FIsMultiSelectable := False;
end;

function TAgentKitProjectManagerMenu.GetCaption: string;
begin
  Result := FCaption;
end;

function TAgentKitProjectManagerMenu.GetChecked: Boolean;
begin
  Result := FChecked;
end;

function TAgentKitProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TAgentKitProjectManagerMenu.GetHelpContext: Integer;
begin
  Result := FHelpContext;
end;

function TAgentKitProjectManagerMenu.GetName: string;
begin
  Result := FName;
end;

function TAgentKitProjectManagerMenu.GetParent: string;
begin
  Result := FParent;
end;

function TAgentKitProjectManagerMenu.GetPosition: Integer;
begin
  Result := FPosition;
end;

function TAgentKitProjectManagerMenu.GetVerb: string;
begin
  Result := FVerb;
end;

procedure TAgentKitProjectManagerMenu.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TAgentKitProjectManagerMenu.SetChecked(Value: Boolean);
begin
  FChecked := Value;
end;

procedure TAgentKitProjectManagerMenu.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TAgentKitProjectManagerMenu.SetHelpContext(Value: Integer);
begin
  FHelpContext := Value;
end;

procedure TAgentKitProjectManagerMenu.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TAgentKitProjectManagerMenu.SetParent(const Value: string);
begin
  FParent := Value;
end;

procedure TAgentKitProjectManagerMenu.SetPosition(Value: Integer);
begin
  FPosition := Value;
end;

procedure TAgentKitProjectManagerMenu.SetVerb(const Value: string);
begin
  FVerb := Value;
end;

function TAgentKitProjectManagerMenu.GetIsMultiSelectable: Boolean;
begin
  Result := FIsMultiSelectable;
end;

procedure TAgentKitProjectManagerMenu.SetIsMultiSelectable(Value: Boolean);
begin
  FIsMultiSelectable := Value;
end;

procedure TAgentKitProjectManagerMenu.Execute(const MenuContextList: IInterfaceList);
begin
  TAgentKitProjectHelper.ExecuteInit(FProject);
end;

function TAgentKitProjectManagerMenu.PreExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

function TAgentKitProjectManagerMenu.PostExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

{ TAgentKitProjectMenuItemCreatorNotifier }

procedure TAgentKitProjectMenuItemCreatorNotifier.AddMenu(const Project: IOTAProject;
  const IdentList: TStrings; const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
begin
  if Assigned(Project) then
  begin
    ProjectManagerMenuList.Add(TAgentKitProjectManagerMenu.Create(Project));
  end;
end;
{$ENDIF}

function FindMenuItemByName(AMenuItem: TMenuItem; const AName: string): TMenuItem;
var
  i: Integer;
  LResult: TMenuItem;
begin
  Result := nil;
  if not Assigned(AMenuItem) then
    Exit;
    
  if SameText(AMenuItem.Name, AName) then
  begin
    Result := AMenuItem;
    Exit;
  end;
  
  for i := 0 to AMenuItem.Count - 1 do
  begin
    LResult := FindMenuItemByName(AMenuItem.Items[i], AName);
    if Assigned(LResult) then
    begin
      Result := LResult;
      Exit;
    end;
  end;
end;

var
  GMenuItemCreatorIndex: Integer = -1;
  GToolsMenuItem: TMenuItem = nil;

procedure Register;
var
  LNTAServices: INTAServices;
  LToolsMenu: TMenuItem;
begin
  // Registro para Delphi 12 e 13 no Project Manager
  {$IF CompilerVersion >= 36.0}
  var LProjManager: IOTAProjectManager;
  if Supports(BorlandIDEServices, IOTAProjectManager, LProjManager) then
  begin
    GMenuItemCreatorIndex := LProjManager.AddMenuItemCreatorNotifier(TAgentKitProjectMenuItemCreatorNotifier.Create);
  end;
  {$ENDIF}

  // Registro alternativo/adicional para Delphi 11 (ou redundante e prático para as demais) no menu principal
  if Supports(BorlandIDEServices, INTAServices, LNTAServices) then
  begin
    LToolsMenu := FindMenuItemByName(LNTAServices.MainMenu.Items, 'ToolsMenu');
    if Assigned(LToolsMenu) then
    begin
      GToolsMenuItem := TMenuItem.Create(LToolsMenu);
      GToolsMenuItem.Caption := 'AgentKit: Initialize Quality Kit';
      GToolsMenuItem.OnClick := TAgentKitMenuHandler.MenuItemClick;
      LToolsMenu.Add(GToolsMenuItem);
    end;
  end;
end;

initialization
finalization
  // Desregistra do Project Manager
  {$IF CompilerVersion >= 36.0}
  if GMenuItemCreatorIndex <> -1 then
  begin
    var LProjManager: IOTAProjectManager;
    if Supports(BorlandIDEServices, IOTAProjectManager, LProjManager) then
    begin
      LProjManager.RemoveMenuItemCreatorNotifier(GMenuItemCreatorIndex);
    end;
  end;
  {$ENDIF}

  // Remove do menu principal Tools
  if Assigned(GToolsMenuItem) then
  begin
    GToolsMenuItem.Free;
  end;
end.
