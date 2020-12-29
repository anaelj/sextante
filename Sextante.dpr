program Sextante;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'uPrincipal.pas' {FormPrincipal},
  uDataModule in 'uDataModule.pas' {DataModule},
  uPopup in 'uPopup.pas' {FormPopup},
  Loading in '..\comum\Loading.pas',
  uFindInHtml in '..\comum\uFindInHtml.pas',
  addPapel in 'addPapel.pas' {frmAddPapel},
  uRequestUrl in 'uRequestUrl.pas' {FormRequestUrl};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape];
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.CreateForm(TDataModule, DataModule);
  Application.CreateForm(TFormPopup, FormPopup);
  Application.CreateForm(TFormPopup, FormPopup);
  Application.CreateForm(TfrmAddPapel, frmAddPapel);
  Application.CreateForm(TFormRequestUrl, FormRequestUrl);
  Application.Run;
end.

