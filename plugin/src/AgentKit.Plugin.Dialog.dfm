object AgentKitDialog: TAgentKitDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'AgentKit: Inicializar Projeto'
  ClientHeight = 360
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object chkConfigureSonar: TCheckBox
    Left = 16
    Top = 18
    Width = 368
    Height = 17
    Caption = 'Configurar suporte ao SonarQube (An'#225'lise Est'#225'tica)'
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = chkConfigureSonarClick
  end
  object grpSonar: TGroupBox
    Left = 16
    Top = 48
    Width = 368
    Height = 250
    Caption = ' Configura'#231#245'es do SonarQube '
    TabOrder = 1
    object lblProjectKey: TLabel
      Left = 16
      Top = 24
      Width = 62
      Height = 15
      Caption = 'Project Key:'
    end
    object lblProjectName: TLabel
      Left = 16
      Top = 74
      Width = 75
      Height = 15
      Caption = 'Project Name:'
    end
    object lblProjectVersion: TLabel
      Left = 16
      Top = 124
      Width = 81
      Height = 15
      Caption = 'Project Version:'
    end
    object lblSonarServerUrl: TLabel
      Left = 16
      Top = 174
      Width = 121
      Height = 15
      Caption = 'SonarQube Server URL:'
    end
    object lblSonarToken: TLabel
      Left = 192
      Top = 174
      Width = 97
      Height = 15
      Caption = 'SonarQube Token:'
    end
    object txtProjectKey: TEdit
      Left = 16
      Top = 42
      Width = 336
      Height = 23
      TabOrder = 0
    end
    object txtProjectName: TEdit
      Left = 16
      Top = 92
      Width = 336
      Height = 23
      TabOrder = 1
    end
    object txtProjectVersion: TEdit
      Left = 16
      Top = 142
      Width = 336
      Height = 23
      TabOrder = 2
    end
    object txtSonarServerUrl: TEdit
      Left = 16
      Top = 192
      Width = 160
      Height = 23
      TabOrder = 3
    end
    object txtSonarToken: TEdit
      Left = 192
      Top = 192
      Width = 160
      Height = 23
      PasswordChar = '*'
      TabOrder = 4
    end
    object chkCreateProjectOnServer: TCheckBox
      Left = 16
      Top = 224
      Width = 336
      Height = 17
      Caption = 'Criar projeto automaticamente no servidor'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 312
    Width = 400
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnOK: TButton
      Left = 224
      Top = 10
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 309
      Top = 10
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
