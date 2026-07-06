unit AgentKit.Plugin.Dialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  AgentKit.Common.Interfaces;

type
  TAgentKitDialog = class(TForm)
    pnlBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    grpSonar: TGroupBox;
    chkConfigureSonar: TCheckBox;
    lblProjectKey: TLabel;
    txtProjectKey: TEdit;
    lblProjectName: TLabel;
    txtProjectName: TEdit;
    lblProjectVersion: TLabel;
    txtProjectVersion: TEdit;
    lblSonarServerUrl: TLabel;
    txtSonarServerUrl: TEdit;
    lblSonarToken: TLabel;
    txtSonarToken: TEdit;
    chkCreateProjectOnServer: TCheckBox;
    procedure chkConfigureSonarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function GetConfig: TProjectInitConfig;
    procedure SetConfig(const Value: TProjectInitConfig);
    procedure UpdateControlStates;
  public
    property Config: TProjectInitConfig read GetConfig write SetConfig;
  end;

var
  AgentKitDialog: TAgentKitDialog;

implementation

{$R *.dfm}

{ TAgentKitDialog }

procedure TAgentKitDialog.FormCreate(Sender: TObject);
begin
  Self.Caption := 'AgentKit: Inicializar Projeto';
  chkConfigureSonar.Caption := 'Configurar suporte ao SonarQube (An'#225'lise Est'#225'tica)';
  grpSonar.Caption := ' Configura'#231#245'es do SonarQube ';
  UpdateControlStates;
end;

procedure TAgentKitDialog.chkConfigureSonarClick(Sender: TObject);
begin
  UpdateControlStates;
end;

procedure TAgentKitDialog.UpdateControlStates;
var
  LEnabled: Boolean;
begin
  LEnabled := chkConfigureSonar.Checked;
  txtProjectKey.Enabled := LEnabled;
  txtProjectName.Enabled := LEnabled;
  txtProjectVersion.Enabled := LEnabled;
  txtSonarServerUrl.Enabled := LEnabled;
  txtSonarToken.Enabled := LEnabled;
  chkCreateProjectOnServer.Enabled := LEnabled;
end;

function TAgentKitDialog.GetConfig: TProjectInitConfig;
begin
  Result.ConfigureSonar := chkConfigureSonar.Checked;
  Result.ProjectKey := Trim(txtProjectKey.Text);
  Result.ProjectName := Trim(txtProjectName.Text);
  Result.ProjectVersion := Trim(txtProjectVersion.Text);
  Result.SonarServerUrl := Trim(txtSonarServerUrl.Text);
  Result.SonarToken := Trim(txtSonarToken.Text);
  Result.CreateProjectOnServer := chkCreateProjectOnServer.Checked;
  Result.ProjectPath := '';
end;

procedure TAgentKitDialog.SetConfig(const Value: TProjectInitConfig);
begin
  chkConfigureSonar.Checked := Value.ConfigureSonar;
  txtProjectKey.Text := Value.ProjectKey;
  txtProjectName.Text := Value.ProjectName;
  txtProjectVersion.Text := Value.ProjectVersion;
  txtSonarServerUrl.Text := Value.SonarServerUrl;
  txtSonarToken.Text := Value.SonarToken;
  chkCreateProjectOnServer.Checked := Value.CreateProjectOnServer;
  UpdateControlStates;
end;

end.
