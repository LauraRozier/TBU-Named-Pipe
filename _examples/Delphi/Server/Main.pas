unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, TBUNamedPipe;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Memo1: TMemo;
    Label2: TLabel;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FConnected: Boolean;
    procedure SetButtons;
  public
    procedure OnConnect(aPipe: Cardinal); stdcall;
    procedure OnDisconnect(aPipe: Cardinal); stdcall;
    procedure OnError(aPipe: Cardinal; aPipeContext: ShortInt; aErrorCode: Integer); stdcall;
    procedure OnMessage(aPipe: Cardinal; aMsg: PWideChar); stdcall;
    procedure OnSent(aPipe, aSize: Cardinal); stdcall;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.SetButtons;
begin
  Button1.Enabled := FConnected;
  Button2.Enabled := FConnected;
  Button3.Enabled := not FConnected;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if PipeServerBroadcast(PWideChar(Edit1.Text)) then
    Memo1.Lines.Add('<< Successfully broadcasted message: ' + Edit1.Text)
  else
    Memo1.Lines.Add('<< Failed to broadcast message: ' + Edit1.Text);

  Edit1.Text := '';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  PipeServerStop;
  Memo1.Lines.Add('<< Pipe server stopped.');
  FConnected := False;
  SetButtons;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  FConnected := PipeServerStart;

  if FConnected then
    Memo1.Lines.Add('<< Pipe server started.')
  else
    Memo1.Lines.Add('<< Unable to start the pipe server.');

  SetButtons;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PipeServerDestroy;
  Inherited;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Inherited;
  SetButtons;
  PipeServerInitialize;
  RegisterOnPipeServerConnectCallback(OnConnect);
  RegisterOnPipeServerDisconnectCallback(OnDisconnect);
  RegisterOnPipeServerErrorCallback(OnError);
  RegisterOnPipeServerMessageCallback(OnMessage);
  RegisterOnPipeServerSentCallback(OnSent);
end;

procedure TForm1.OnConnect(aPipe: Cardinal); stdcall;
begin
  Memo1.Lines.Add('>> New pipe (' + IntToStr(aPipe) + ') connected.');
end;

procedure TForm1.OnDisconnect(aPipe: Cardinal); stdcall;
begin
  Memo1.Lines.Add('>> Pipe (' + IntToStr(aPipe) + ') disconnected.');
end;

procedure TForm1.OnError(aPipe: Cardinal; aPipeContext: ShortInt; aErrorCode: Integer); stdcall;
begin
  Memo1.Lines.Add('>> Pipe (' + IntToStr(aPipe) +
                  ') generated error (' + IntToStr(aErrorCode) +
                  ') in the ' + PipeContextToString(aPipeContext) +
                  ' context.');
end;

procedure TForm1.OnMessage(aPipe: Cardinal; aMsg: PWideChar); stdcall;
begin
  Memo1.Lines.Add('>> Pipe (' + IntToStr(aPipe) +
                  ') sent a message: ' + StrPas(aMsg));
end;

procedure TForm1.OnSent(aPipe: Cardinal; aSize: Cardinal); stdcall;
begin
  Memo1.Lines.Add('>> Pipe (' + IntToStr(aPipe) +
                  ') received our message with a length of (' + IntToStr(aPipe) + ').');
end;

end.
