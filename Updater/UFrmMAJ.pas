{$I Directives.inc}
unit UFrmMAJ;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ShellApi, UDownloadThread
  {$IFDEF EnableXPMan}, XPMan{$ENDIF};

type
  { Les différents états de la fiche
  (les étapes de l'assistant si vous préférez) }
  TFrmMAJState = (fmsNothing, fmsNeedDownload, fsmDownloading,
   fmsReadyToInstall, fmsInstalling, fmsCompleted, fmsCancelled);

  TFrmMAJ = class(TForm)
    pTop: TPanel;
    pCenter: TPanel;
    pBottom: TPanel;
    BtnNext: TButton;
    BtnCancel: TButton;
    BtnHide: TButton;
    LblInfo: TLabel;
    PB: TProgressBar;
    LblInfo2: TLabel;
    PB2: TProgressBar;
    LblTopInfo: TLabel;
    Fond: TShape;
    procedure FormCreate(Sender: TObject);
    procedure BtnHideClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Handle vers qqch dont on attend la fin avan de commencer l'installation }
    FWaitHandle: THandle;
    {Liste des fichiers à mettre à jour ainsi que leur source }
    FSourceFiles: TStringList;
    FDestFiles: TStringList;
    { Ligne de commande à executer après la mise à jour }
    FCmdLine: string;
    { Thread de téléchargement et variable our savoir si on télécharge ou pas }
    FDownloading: Boolean;
    FDownloadThread: TDownloadThread;
    { Gère le téléchargement }
    procedure DownloadFiles;
    procedure DownloadTerminated(Sender: TObject);
    { Copie les fichiers }
    procedure InstallFiles;
  public
    { Etat de la fiche }
    FFrmState: TFrmMAJState;
    { Liste des fichiers à récupérer d'Internet }
    FInternetFiles: TStringList;
    procedure NextState;
    procedure ShowState;
  end;

const
  { Liste des états permettant de quitter l'application }
  CQuitStates: set of TFrmMAJState = [fmsNothing, fmsCompleted, fmsCancelled];
  CTempFileFmt = '%sTempUpdateFile%d.tmp';

  { Génère un nom de fichier unique pour une URL donnée (par hash) }
  function GetTempFileName(const AFileName: string): string;

var
  FrmMAJ: TFrmMAJ;

implementation

{$R *.dfm}

function GetTempFileName(const AFileName: string): string;

  function HashString(const Key: string): Cardinal;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 1 to Length(Key) do
      Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
        Ord(Key[I]);
  end;

begin
  Result := ExtractFilePath(ParamStr(0)) + 'File' +
    IntToHex(HashString(AFileName), 8) + '.tmp';
end;

procedure TFrmMAJ.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  {>> Init }
  FDownloading := False;
  FWaitHandle := 0;
  FCmdLine := '';
  FFrmState := fmsNothing;
  FSourceFiles := TStringList.Create;
  FDestFiles := TStringList.Create;
  FInternetFiles := TStringList.Create;

  {>> Récupération des paramètres }
  I := 1;
  while I < ParamCount do
  begin
    {>> Cas du handle d'attente }
    if AnsiSameText(Copy(ParamStr(I), 2, 4), 'wait') then
      FWaitHandle := StrToIntDef(ParamStr(I + 1), 0)

    {>> Cas de la ligne de commande }
    else if AnsiSameText(Copy(ParamStr(I), 2, 4), 'exec') then
      FCmdLine := ParamStr(I + 1)

    {>> Sinon, c'est une paire de fichiers }
    else
    begin
      FSourceFiles.Add(ParamStr(I));
      FDestFiles.Add(ParamStr(I + 1));
    end;
    Inc(I, 2);
  end;

  {>> Traitement spécial de la liste pour les fichiers qui sont à télécharger:
  - On ajoute l'URL initiale à FInternetFile.
  - On remplace FSourceFiles[I] par un fichier temporaire. }
  if FSourceFiles.Count > 0 then
  begin
    FFrmState := fmsReadyToInstall;
    for I := 0 to FSourceFiles.Count - 1 do
      if AnsiSameText(Copy(FSourceFiles[I], 1, 7), 'http://') then
      begin
        FFrmState := fmsNeedDownload;
        FInternetFiles.Add(FSourceFiles[I]);
        FSourceFiles[I] := GetTempFileName(FSourceFiles[I]);
      end;
  end;

  {>> Affichage de l'état }
  ShowState;
end;

procedure TFrmMAJ.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  if FDownloading then  // Pas logique mais sait-on jamais ...
    FDownloadThread.Terminate;

  {>> Supprime les fichiers temporaires }
  for I := 0 to FInternetFiles.Count - 1 do
    DeleteFile(GetTempFileName(FInternetFiles[I]));

  {>> Libération }
  FSourceFiles.Free;
  FDestFiles.Free;
  FInternetFiles.Free;

  {>> Execution de la commande finale si réussite }
  if (FCmdLine <> '') and (FFrmState = fmsCompleted) then
  begin
    Sleep(100);
    ShellExecute(0, 'OPEN', PChar(FCmdLine), '/updated', nil, 0);
  end;
end;

procedure TFrmMAJ.NextState;
begin
  FFrmState := Succ(FFrmState);
  ShowState;
end;

procedure TFrmMAJ.ShowState;
begin
  {>> Etat par défaut des composants }
  PB.Visible := False;
  PB2.Visible := False;
  BtnCancel.Enabled := False;
  BtnNext.Enabled := False;
  BtnNext.Caption := 'Next >';
  LblInfo2.Visible := False;

  {>> Modifie les composants suivant l'état }
  case FFrmState of
    fmsNothing:
    begin
      LblTopInfo.Caption := '  Any bets à day';
      LblInfo.Caption := 'Aucune mise à jour n''a été trouvée. ' + sLineBreak +
                         'Cliquez sur Terminer pour quitter.';
      BtnNext.Enabled := True;
      BtnNext.Caption := 'Terminate';
    end;
    fmsNeedDownload:
    begin
      LblTopInfo.Caption := '  Download confirmation';
      LblInfo.Caption := 'Certains fichiers ont besoin d''être téléchargés ' +
                         'poursuivre la mise à jour. ' + sLineBreak +
                         'Cliquez sur Suivant pour les récupérer.';
      BtnCancel.Enabled := True;
      BtnNext.Enabled := True;
    end;
    fsmDownloading:
    begin
      LblTopInfo.Caption := '  Downloading ...';
      LblInfo.Caption := 'Downloading in progress...';
      LblInfo2.Caption := 'Initialisation downloading ...';
      LblInfo2.Visible := True;
      PB.Visible := True;
      PB2.Visible := True;
      BtnCancel.Enabled := True;
      DownloadFiles;
    end;
    fmsReadyToInstall:
    begin
      LblTopInfo.Caption := '  Installation';
      LblInfo.Caption := 'Des mises à jour sont prêtes à être installées.' +
                         sLineBreak + 'Cliquez sur Suivant pour continuer.';
      BtnCancel.Enabled := True;
      BtnNext.Enabled := True;
    end;
    fmsInstalling:
    begin
      LblTopInfo.Caption := '  Installation';
      LblInfo.Caption := 'Les mises à jour sont en cours d''installation' +
                         sLineBreak + 'Veuillez patienter ...';
      PB.Visible := True;
      InstallFiles;
    end;
    fmsCompleted:
    begin
      LblTopInfo.Caption := '  Installation terminate';
      LblInfo.Caption := 'Les mises à jour ont été correctement installées. ' +
                         'Vous disposez maintenant de la toute dernière ' +
                         'version du lociciel.' + sLineBreak + 'Cliquez sur ' +
                         'Terminer pour quitter.';
      BtnNext.Enabled := True;
      BtnNext.Caption := 'Terminate';
    end;
    fmsCancelled:
    begin
      LblTopInfo.Caption := '  Abandon';
      LblInfo.Caption := 'Le lociciel n''a pas été mis à jour en raison ' +
                         'd''une interruption.' + sLineBreak + 'Cliquez sur ' +
                         'Terminer pour quitter.';
      BtnNext.Enabled := True;
      BtnNext.Caption := 'Terminate';
    end;
  end;
  Application.Restore;
  BringToFront;
end;

procedure TFrmMAJ.DownloadFiles;
begin
  FDownloadThread := TDownloadThread.Create;
  FDownloadThread.OnTerminate := DownloadTerminated;
  FDownloading := True;
end;

procedure TFrmMAJ.DownloadTerminated(Sender: TObject);
begin
  FDownloading := False;
  FDownloadThread := nil;
end;

procedure TFrmMAJ.InstallFiles;
var
  I: Integer;
begin
  {>> Attend que l'application se termine }
  if FWaitHandle <> 0 then
    if WaitForSingleObject(FWaitHandle, 5000) = WAIT_TIMEOUT then
    begin
      FFrmState := fmsCancelled;
      ShowState;
      LblInfo2.Visible := True;
      LblInfo2.Caption := 'Error info: application a dépassé le' +
                          'délai d''attente pour se fermer.';
      Exit;
    end;

  {>> Remplacement des fichiers }
  for I := 0 to FSourceFiles.Count - 1 do
  begin
    ForceDirectories(ExtractFilePath(FDestFiles[I]));
    if not CopyFile(PChar(FSourceFiles[I]), PChar(FDestFiles[I]), False) then
    begin
      FFrmState := fmsCancelled;
      ShowState;
      LblInfo2.Visible := True;
      LblInfo2.Caption := 'Error info: file "' + FSourceFiles[I] +
                          '" not exist.';
      Exit;
    end;
  end;

  {>> Passe à l'étape d'après }
  NextState;
end;

procedure TFrmMAJ.BtnNextClick(Sender: TObject);
begin
  if FFrmState in CQuitStates then
    Close
  else
    NextState;
end;

procedure TFrmMAJ.BtnCancelClick(Sender: TObject);
begin
  if MessageDlg('Exit from updater?', mtConfirmation,
   [mbYes, mbNo], 0) = mrYes then
  begin
    if FDownloading then
      FDownloadThread.Terminate;
    FFrmState := fmsCancelled;
    ShowState;
  end;
end;

procedure TFrmMAJ.BtnHideClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TFrmMAJ.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FFrmState in CQuitStates;
  if not CanClose then
    BtnCancelClick(nil);
end;

end.
