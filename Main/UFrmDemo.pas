{$I Directives.inc}
unit UFrmDemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, AppUpdater{$IFDEF EnableXPMan}, XPMan{$ENDIF};

type
  TFrmDemo = class(TForm)
    Image: TImage;
    memoDescription: TMemo;
    BtnCheckMAJ: TButton;
    LblInfo: TLabel;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnCheckMAJClick(Sender: TObject);
  private
    FAppUpdater: TApplicationUpdater;
    procedure CheckUpdates(SourceFileList, DestFileList: TStrings);
    procedure UpdatesAvailable(var PerformUpdates: Boolean);
  end;

var
  FrmDemo: TFrmDemo;

const
  { Ces constantes contiennent les infos sur les fichiers à mettre à jour }
  CBaseURL = 'http://storage.florenth.googlepages.com/';
  CFilesURL: array[0..2] of string = ('egalite_hf', 'picasso_replique',
   'sens_interdit');
  CDescription = 'description.txt';
  CImage = 'images.bmp';

  { Messages du programme }
  CUpdatedMsg = 'The program was updated.';
  CUpdatesAvailable = 'New updates is available. ' + sLineBreak +
                      'Install it?';

implementation

{$R *.dfm}

procedure TFrmDemo.FormCreate(Sender: TObject);
begin
  {>> Création du composant }
  FAppUpdater := TApplicationUpdater.Create(Self);
  FAppUpdater.OnUpdatesCheck := CheckUpdates;
  FAppUpdater.OnUpdatesAvailable := UpdatesAvailable;
  FAppUpdater.UpdaterFileName := ExtractFilePath(ExtractFileDir(ParamStr(0))) +
    'Updater\updater.exe';

  {>> Chargement de l'image et de sa description }
  if FileExists(CImage) and FileExists(CDescription) then
  begin
    Image.Picture.LoadFromFile(CImage);
    memoDescription.Lines.LoadFromFile(CDescription);
  end;

  {>> Si on reçoit un paramètre "/updated" c'est que la MAJ s'est bien passée
  Ici, ça ne sert qu'a changer le caption d'un label }
  if (ParamCount = 1) and (ParamStr(1) = '/updated') then
    LblInfo.Caption := CUpdatedMsg
  else
    LblInfo.Caption := '';
end;

procedure TFrmDemo.BtnCheckMAJClick(Sender: TObject);
begin
  FAppUpdater.CheckForUpdates;
end;

procedure TFrmDemo.CheckUpdates(SourceFileList, DestFileList: TStrings);
var
  I: Integer;
begin
  {>> On dit tout le temps qu'il y a qqch à mettre à jour !
  Utilisation de Random() pour avoir des mises à jour aléatoires.
  En réalité, un programme ferait une requette sur Internet pour déterminer
  s'il y a une nouvelle version ou pas }
  Randomize;
  I := Random(3);
  SourceFileList.Add(CBaseURL + CFilesURL[I] + '.txt');
  SourceFileList.Add(CBaseURL + CFilesURL[I] + '.bmp');
  DestFileList.Add(ExtractFilePath(ParamStr(0)) + CDescription);
  DestFileList.Add(ExtractFilePath(ParamStr(0)) + CImage);
end;

procedure TFrmDemo.UpdatesAvailable(var PerformUpdates: Boolean);
begin
  PerformUpdates := MessageDlg(CUpdatesAvailable, mtConfirmation,
  [mbYes, mbNo], 0) = mrYes;
end;

end.
