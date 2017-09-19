unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, TBUNamedPipe;

type
  TForm2 = class(TForm)
    Memo1: TMemo;
    Label2: TLabel;
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FConnected: Boolean;
    procedure SetButtons;
  public
    procedure OnDisconnect(aPipe: Cardinal); stdcall;
    procedure OnError(aPipe: Cardinal; aPipeContext: ShortInt; aErrorCode: Integer); stdcall;
    procedure OnMessage(aPipe: Cardinal; aMsg: PWideChar); stdcall;
    procedure OnSent(aPipe, aSize: Cardinal); stdcall;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.SetButtons;
begin
  Button1.Enabled := FConnected;
  Button2.Enabled := FConnected;
  Button3.Enabled := not FConnected;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if PipeClientSend(PWideChar(Edit1.Text)) then
    Memo1.Lines.Add('<< Successfully sent message: ' + Edit1.Text)
  else
    Memo1.Lines.Add('<< Failed to send message: ' + Edit1.Text);

  Edit1.Text := '';
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  PipeClientDisconnect;
  Memo1.Lines.Add('<< Pipe client disconnected.');
  FConnected := False;
  SetButtons;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  FConnected := PipeClientConnect;

  if FConnected then
    Memo1.Lines.Add('<< Pipe client connected.')
  else
    Memo1.Lines.Add('<< Unable to connect to the pipe server.');

  SetButtons;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PipeClientDestroy;
  Inherited;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Inherited;
  SetButtons;
  PipeClientInitialize;
  RegisterOnPipeClientDisconnectCallback(OnDisconnect);
  RegisterOnPipeClientErrorCallback(OnError);
  RegisterOnPipeClientMessageCallback(OnMessage);
  RegisterOnPipeClientSentCallback(OnSent);
end;

procedure TForm2.OnDisconnect(aPipe: Cardinal); stdcall;
begin
  Memo1.Lines.Add('>> Pipe (' + IntToStr(aPipe) + ') disconnected.');
end;

procedure TForm2.OnError(aPipe: Cardinal; aPipeContext: ShortInt; aErrorCode: Integer); stdcall;
begin
  Memo1.Lines.Add('>> Pipe (' + IntToStr(aPipe) +
                  ') generated error (' + IntToStr(aErrorCode) +
                  ') in the ' + PipeContextToString(aPipeContext) +
                  ' context.');
end;

procedure TForm2.OnMessage(aPipe: Cardinal; aMsg: PWideChar); stdcall;
begin
  Memo1.Lines.Add('>> Pipe (' + IntToStr(aPipe) +
                  ') sent a message: ' + StrPas(aMsg));
end;

procedure TForm2.OnSent(aPipe: Cardinal; aSize: Cardinal); stdcall;
begin
  Memo1.Lines.Add('>> Pipe (' + IntToStr(aPipe) +
                  ') received our message with a length of (' + IntToStr(aPipe) + ').');
end;

end.
