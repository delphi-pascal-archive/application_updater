{$I Directives.inc}
unit UDownloadThread;

interface

uses
  SysUtils, Classes, Forms, IdComponent, IdHTTP;

type
{>> Compatibilité Indy9 <-> Indy10 }
{-$DEFINE Indy10}

  TDownloadThread = class(TThread)
  private
    FHTTP: TIdHTTP;
    FFileNum: Integer;
    FWorkCount: Integer;
    FWorkCountMax: Integer;
  protected
    procedure Execute; override;
    procedure WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
     {$IFNDEF Indy10}const{$ENDIF} AWorkCountMax: Integer);
    procedure WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure Work(ASender: TObject; AWorkMode: TWorkMode;
     {$IFNDEF Indy10}const{$ENDIF} AWorkCount: Integer);
    procedure DoUpdateForm;
    procedure DoFinish;
    procedure DoFail;
  public
    constructor Create;
    procedure Terminate; reintroduce;
  end;

implementation

uses
  UFrmMAJ;

constructor TDownloadThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate := True;
end;

procedure TDownloadThread.Terminate;
begin
  inherited Terminate;
  if Assigned(FHTTP) and FHTTP.Connected then
{$IFDEF Indy10}
  // Ceci évite sous Indy10 d'avoir une exception "normale" 
  FHTTP.DisconnectNotifyPeer;
{$ELSE}
  FHTTP.Disconnect;
{$ENDIF}
end;

procedure TDownloadThread.Execute;
var
  Stream: TFileStream;
  I: Integer;
begin
  FHTTP := TIdHTTP.Create(nil);
  try
    FHTTP.OnWorkBegin := WorkBegin;
    FHTTP.OnWorkEnd := WorkEnd;
    FHTTP.OnWork := Work;
    {>> Téléchargement des fichiers }
    for I := 0 to FrmMAJ.FInternetFiles.Count - 1 do
    begin
      { Arrète si demandé }
      if Terminated then
        Exit;

      { Retient l'indice de boucle en global }
      FFileNum := I;

      { Crée le flux }
      Stream := TFileStream.Create(GetTempFileName(FrmMAJ.FInternetFiles[I]),
       fmCreate);
      try
        try
          FHTTP.Get(FrmMAJ.FInternetFiles[I], Stream);
        except
          Synchronize(DoFail);
        end;
      finally
        Stream.Free;
      end;
    end;
    { Si tous les téléchargements ont fini normalement, on notifie }
    if not Terminated then
      Synchronize(DoFinish);
  finally
    FHTTP.Free;
  end;
end;

procedure TDownloadThread.WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
 {$IFNDEF Indy10}const{$ENDIF} AWorkCountMax: Integer);
begin
  FWorkCount := 0;
  FWorkCountMax := AWorkCountMax;
  Synchronize(DoUpdateForm);
end;

procedure TDownloadThread.WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  FWorkCount := 0;
  Synchronize(DoUpdateForm);
end;

procedure TDownloadThread.Work(ASender: TObject; AWorkMode: TWorkMode;
 {$IFNDEF Indy10}const{$ENDIF} AWorkCount: Integer);
begin
  FWorkCount := AWorkCount;
  Synchronize(DoUpdateForm);
end;

procedure TDownloadThread.DoUpdateForm;
begin
  if Terminated then
    Exit;
  with FrmMAJ do
  begin
    PB.Min := 0;
    PB.Max := 1000;
    PB.Position := FWorkCount * 1000 div FWorkCountMax;
    PB2.Min := 0;
    PB2.Max := FrmMAJ.FInternetFiles.Count;
    PB2.Position := FFileNum;
    LblInfo2.Caption := Format('Downloading file (%d of %d)'+
     sLineBreak + '%s (%.1f%%)', [FFileNum + 1, FrmMAJ.FInternetFiles.Count,
     FrmMAJ.FInternetFiles[FFileNum], FrmMAJ.PB.Position / 10]);
    LblInfo2.Visible := True;
  end;
end;

procedure TDownloadThread.DoFinish;
begin
  with FrmMAJ do
  begin
    PB.Position := 0;
    PB2.Position := 0;
    LblInfo2.Caption := '';
    NextState;
  end;
end;

procedure TDownloadThread.DoFail;
begin
  with FrmMAJ do
  begin
    FFrmState := fmsCancelled;
    ShowState;
    LblInfo2.Visible := True;
    LblInfo2.Caption := 'Error info: impossible download a ' +
                        'file "' + FrmMAJ.FInternetFiles[FFileNum] + '".';
  end;
end;

end.
