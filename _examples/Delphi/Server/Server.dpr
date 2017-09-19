program Server;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  TBUNamedPipe in '..\..\..\_wrappers\TBUNamedPipe.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
