program Client;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form2},
  TBUNamedPipe in '..\..\..\_wrappers\TBUNamedPipe.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
