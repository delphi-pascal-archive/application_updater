{$I Directives.inc}
unit AppUpdater;

interface

uses
  Windows, SysUtils, Classes, Forms, ShellApi, dialogs;

type
  TAppUpdaterCheckEvent = procedure (SourceFileList,
   DestFileList: TStrings) of object;
  TAppUpdatesAvailableEvent = procedure (var PerformUpdates: Boolean) of object;

  TApplicationUpdater = class(TComponent)
  private
    { Liste des fichiers � mettre � jour }
    FSourceFiles: TStringList;
    FDestFiles: TStringList;
    { Localisation de l'updater }
    FUpdaterFileName: string;
    { Commande � executer apr�s la mise � jour (par d�faut relance
    l'application) Ajoute toujours le param�tre "/updated" � la ligne }
    FCmdLine: string;
    { Evenements }
    FOnUpdatesCheck: TAppUpdaterCheckEvent;
    FOnUpdatesAvailable: TAppUpdatesAvailableEvent;
    { Setter }
    procedure SetUpdaterFileName(const Value: string);
  protected
    procedure PerformUpdates;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CheckForUpdates;
    property UpdaterFileName: string read FUpdaterFileName
     write SetUpdaterFileName;
  published
    property OnUpdatesCheck: TAppUpdaterCheckEvent read FOnUpdatesCheck
     write FOnUpdatesCheck;
    property OnUpdatesAvailable: TAppUpdatesAvailableEvent
     read FOnUpdatesAvailable write FOnUpdatesAvailable;
  end;

implementation

constructor TApplicationUpdater.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSourceFiles := TStringList.Create;
  FDestFiles := TStringList.Create;
  FCmdLine := '"' + ParamStr(0) + '"';
  FUpdaterFileName := ExtractFilePath(ParamStr(0)) + 'updater.exe';
end;

destructor TApplicationUpdater.Destroy;
begin
  FSourceFiles.Free;
  FDestFiles.Free;
  inherited Destroy;
end;

procedure TApplicationUpdater.CheckForUpdates;
var
  DoUpdates: Boolean;
begin
  {>> Appel de l'�venement pour obtenir la liste des fichiers � mettre � jour }
  if Assigned(FOnUpdatesCheck) then
    FOnUpdatesCheck(FSourceFiles, FDestFiles);

  {>> V�rification logique }
  if FSourceFiles.Count <> FDestFiles.Count then
    raise Exception.Create('Need same number of files');

  {>> Traitement s'il y a des mises � jour }
  if FSourceFiles.Count > 0 then
  begin
    {>> Appel de l'�venement pour savoir s'il faut mettre � jour les fichiers }
    DoUpdates := True;
    if Assigned(FOnUpdatesAvailable) then
      FOnUpdatesAvailable(DoUpdates);

    {>> MAJ si demand� }
    if DoUpdates then
      PerformUpdates;
  end;
end;

procedure TApplicationUpdater.PerformUpdates;
var
  S: string;
  I: Integer;
begin
  {>> Ajout des fichiers � la ligne de commande }
  for I := 0 to FSourceFiles.Count - 1 do
    S := S + ' "' + FSourceFiles[I] + '" "' + FDestFiles[I] + '"';

  {>> Vide les listes }
  FSourceFiles.Clear;
  FDestFiles.Clear;

  {>> Ajout de la commande � executer }
  if FCmdLine <> '' then
    S := S + ' /exec ' + FCmdLine;

  {>> Ajout du handle d'attente pour �viter que le programme soit mis � jour
  s'il n'a pas eu le temps de se fermer }
  S := S + ' /wait ' + IntToStr(GetCurrentThread);

  {>> Lancement de la commande }
  ShellExecute(0, 'OPEN', PChar(FUpdaterFileName), PChar(S), nil, 0);

  {>> Fermeture de l'application }
  Application.Terminate;
end;

procedure TApplicationUpdater.SetUpdaterFileName(const Value: string);
begin
  if FileExists(Value) then
    FUpdaterFileName := Value;
end;

end.
