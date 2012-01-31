unit uPrincipal;

interface

uses
  Synaser,

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ACBrSMSClass, ACBrSMS, StdCtrls, ACBrSMSDaruma, ACBrBase,
  ExtCtrls, ComCtrls, Menus, jpeg, ACBrGIF;

type
  TfrmPrincipal = class(TForm)
    ACBrSMS1: TACBrSMS;
    GroupBox5: TGroupBox;
    btnAtivar: TButton;
    cbxPorta: TComboBox;
    cbxVelocidade: TComboBox;
    cbxModelo: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MainMenu1: TMainMenu;
    Informaes1: TMenuItem;
    menEmLinha: TMenuItem;
    menIMEI: TMenuItem;
    menOperadora: TMenuItem;
    menNivelSinal: TMenuItem;
    menModelo: TMenuItem;
    menFabricante: TMenuItem;
    menFirmware: TMenuItem;
    Mtodos1: TMenuItem;
    menMensagemEnviar: TMenuItem;
    menMensagemListar: TMenuItem;
    menTrocarBandeja: TMenuItem;
    pBotoes: TPanel;
    Image1: TImage;
    Sobre1: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure btnAtivarClick(Sender: TObject);
    procedure menEmLinhaClick(Sender: TObject);
    procedure menIMEIClick(Sender: TObject);
    procedure menNivelSinalClick(Sender: TObject);
    procedure menModeloClick(Sender: TObject);
    procedure menFabricanteClick(Sender: TObject);
    procedure menFirmwareClick(Sender: TObject);
    procedure Sobre1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure menOperadoraClick(Sender: TObject);
    procedure menMensagemEnviarClick(Sender: TObject);
    procedure menMensagemListarClick(Sender: TObject);
    procedure menTrocarBandejaClick(Sender: TObject);
  private
    procedure AtivarMenus(const AAtivar: Boolean);
    function PathIni: String;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  IniFiles, StrUtils, TypInfo,
  uListaMensagem, uTrocarBandeja, uEnviarMensagem;

{$R *.dfm}

function TfrmPrincipal.PathIni: String;
begin
  Result :=
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini');
end;

procedure TfrmPrincipal.AtivarMenus(const AAtivar: Boolean);
var
  I: Integer;
begin
  for I := 0 to MainMenu1.Items.Count - 1 do
    MainMenu1.Items[I].Enabled := AAtivar;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
  I: TACBrSMSModelo;
begin
  // Popular combobox dos modelos
  cbxModelo.Items.Clear ;
  for I := Low(TACBrSMSModelo) to High(TACBrSMSModelo) do
    cbxModelo.Items.Add( GetEnumName(TypeInfo(TACBrSMSModelo), integer(I) ) ) ;

  // listar portas seriais do computador
  ACBrSMS1.Device.AcharPortasSeriais(cbxPorta.Items);

  // Ler configura��es
  Ini := TIniFile.Create(PathIni);
  try
    cbxModelo.ItemIndex := cbxModelo.Items.IndexOf(Ini.ReadString('CONFIG', 'Modelo', 'modNenhum'));
    cbxPorta.ItemIndex  := cbxPorta.Items.IndexOf(Ini.ReadString('CONFIG', 'Porta', 'COM1'));
    cbxVelocidade.Text  := Ini.ReadString('CONFIG', 'Velocidade', '115200');
  finally
    Ini.Free;
  end;

  // desativar todos os menus at� a ativa��o do componente
  AtivarMenus(False);
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  ACBrSMS1.Desativar;
end;

procedure TfrmPrincipal.btnAtivarClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  if not ACBrSMS1.Ativo then
  begin
    ACBrSMS1.Modelo       := TACBrSMSModelo(cbxModelo.ItemIndex);
    ACBrSMS1.Device.Porta := cbxPorta.Text;
    ACBrSMS1.Device.Baud  := StrToInt(cbxVelocidade.Text);
    ACBrSMS1.Ativar;

    btnAtivar.Caption := 'Desativar';
    AtivarMenus(True);

    // grava��o das ultimas configura��es v�lidas
    Ini := TIniFile.Create(PathIni);
    try
      Ini.WriteString('CONFIG', 'Modelo', cbxModelo.Text);
      Ini.WriteString('CONFIG', 'Porta', cbxPorta.Text);
      Ini.WriteString('CONFIG', 'Velocidade', cbxVelocidade.Text);
    finally
      Ini.Free;
    end;
  end
  else
  begin
    ACBrSMS1.Desativar;
    btnAtivar.Caption := 'Ativar';
    AtivarMenus(False);
  end;
end;

procedure TfrmPrincipal.menEmLinhaClick(Sender: TObject);
var
  Msg: String;
begin
  Msg := IfThen(ACBrSMS1.EmLinha, 'SMS em linha', 'SMS n�o est� em linha.');
  ShowMessage(Msg);
end;

procedure TfrmPrincipal.menFabricanteClick(Sender: TObject);
begin
  ShowMessage(
    'Fabricante: ' +
    sLineBreak +
    sLineBreak +
    String(ACBrSMS1.Fabricante)
  );
end;

procedure TfrmPrincipal.menFirmwareClick(Sender: TObject);
begin
  ShowMessage(
    'Firmware: ' +
    sLineBreak +
    sLineBreak +
    String(ACBrSMS1.Firmware)
  );
end;

procedure TfrmPrincipal.menIMEIClick(Sender: TObject);
begin
  ShowMessage(
    'IMEI: ' +
    sLineBreak +
    sLineBreak +
    String(ACBrSMS1.IMEI)
  );
end;

procedure TfrmPrincipal.menMensagemEnviarClick(Sender: TObject);
begin
  frmEnviarMensagem := TfrmEnviarMensagem.Create(Self);
  try
    frmEnviarMensagem.ShowModal;
  finally
    FreeAndNil(frmEnviarMensagem);
  end;
end;

procedure TfrmPrincipal.menMensagemListarClick(Sender: TObject);
begin
  frmListaMensagem := TfrmListaMensagem.Create(Self);
  try
    frmListaMensagem.ShowModal;
  finally
    FreeAndNil(frmListaMensagem);
  end;
end;

procedure TfrmPrincipal.menModeloClick(Sender: TObject);
begin
  ShowMessage(
    'Modelo modem: ' +
    sLineBreak +
    sLineBreak +
    String(ACBrSMS1.ModeloModem)
  );
end;

procedure TfrmPrincipal.menNivelSinalClick(Sender: TObject);
begin
  ShowMessage(
    'N�vel de Sinal: ' +
    sLineBreak +
    sLineBreak +
    FloatToStr(ACBrSMS1.NivelSinal)
  );
end;

procedure TfrmPrincipal.menOperadoraClick(Sender: TObject);
begin
  ShowMessage(
    'Operadora: ' +
    sLineBreak +
    sLineBreak +
    String(ACBrSMS1.Operadora)
  );
end;

procedure TfrmPrincipal.menTrocarBandejaClick(Sender: TObject);
begin
  frmTrocarBandeja := TfrmTrocarBandeja.Create(Self);
  try
    frmTrocarBandeja.ShowModal;
  finally
    FreeAndNil(frmTrocarBandeja);
  end;
end;

procedure TfrmPrincipal.Sobre1Click(Sender: TObject);
begin
  ACBrAboutDialog;
end;

end.