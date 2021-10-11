program Updater;

uses
  Forms,
  UFrmMAJ in 'UFrmMAJ.pas' {FrmMAJ},
  UDownloadThread in 'UDownloadThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMAJ, FrmMAJ);
  Application.Run;
end.
