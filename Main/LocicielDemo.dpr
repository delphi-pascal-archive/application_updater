program LocicielDemo;

uses
  Forms,
  UFrmDemo in 'UFrmDemo.pas' {FrmDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmDemo, FrmDemo);
  Application.Run;
end.
