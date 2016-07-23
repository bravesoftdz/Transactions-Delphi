  unit frmEmployees;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.Win.ADODB, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Buttons,
  Vcl.Imaging.pngimage, Vcl.ComCtrls, Vcl.WinXCtrls;

type
  TfmEmployees = class(TForm)
    Panel1: TPanel;
    BtnDelete: TButton;
    BtnUpdate: TButton;
    BtnAdd: TButton;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    ADOConnection: TADOConnection;
    qEmployees: TADOQuery;
    ADODataSet1: TADODataSet;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    qOrders: TADOQuery;
    DataSource3: TDataSource;
    qTerritory: TADOQuery;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BtnSave: TButton;
    Timer1: TTimer;
    LabelConfirmMessage: TLabel;
    Image1: TImage;
    BtnCancel: TButton;
    procedure ConfirmationMessage(confirmMessage : string);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnUpdateClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmEmployees: TfmEmployees;

implementation

{$R *.dfm}

procedure TfmEmployees.BtnDeleteClick(Sender: TObject);
var
    selectedemployee : string;
begin
  try
    if MessageDlg('Are you sure you want to delete this Employee?    *'+ dbgrid1.DataSource.DataSet.FieldByName('firstname').AsString
    + ' ' +dbgrid1.DataSource.DataSet.FieldByName('lastname').AsString, mtConfirmation,[mbYes,mbNo],0,mbYes) = mrYes then
    begin
      adoconnection.BeginTrans;
      try
        selectedEmployee := dbgrid1.DataSource.DataSet.FieldByName('employeeid').AsString;

        qterritory.SQL.Text := 'delete from employeeterritories where employeeid = ' + quotedstr(selectedEmployee );
        qorders.SQL.Text := 'update orders set employeeid = null where employeeid = ' + quotedstr(selectedEmployee);
        qemployees.SQL.Text := 'delete from employees where employeeid = ' + quotedstr(selectedEmployee);

        qterritory.ExecSQL;
        qorders.ExecSQL;
        qemployees.ExecSQL;

        adoconnection.CommitTrans;
        ConfirmationMessage('Delete Successful');
      except
        on E : EdatabaseError do
          begin
          adoconnection.RollbackTrans;
          showmessage('Error: ' + E.Message);
          end;

      end;

    end;
  finally
    qemployees.SQL.Clear;
    qterritory.SQL.Clear;
    qorders.SQL.Clear;
    qemployees.Sql.Add('select * from employees');
    qterritory.SQL.Add('select * from employeeterritories');
    qorders.SQL.Add('select * from orders');
    qemployees.ExecSQL;
    qterritory.ExecSQL;
    qorders.ExecSQL;
    qemployees.Active := true;
    qterritory.Active := true;
    qorders.Active := true;
  end;

end;

procedure TfmEmployees.BtnSaveClick(Sender: TObject);
begin
  try
  qemployees.Post;
  BtnSave.Visible := false;
  BtnCancel.Visible := false;
  BtnAdd.Visible := true;
  ConfirmationMessage('New Employee added');
  except
    on E : EdatabaseError do
    showmessage('Error: ' + E.Message);
  end;
end;

procedure TfmEmployees.BtnUpdateClick(Sender: TObject);
begin
  try
  qemployees.Edit;
  qemployees.Post;
  finally
    ConfirmationMessage('Employee info updated.');
    BtnUpdate.Enabled := false;
  end;
end;


procedure TfmEmployees.BtnCancelClick(Sender: TObject);
begin
  qemployees.Cancel;
  BtnAdd.Visible := true;
  BtnCancel.Visible := false;
  BtnSave.Visible := false;
end;

procedure TfmEmployees.ConfirmationMessage(confirmMessage: string);
begin
  Image1.Visible := true;
  LabelConfirmMessage.Visible := true;
  LabelConfirmMessage.Caption := confirmMessage;

  Timer1.Enabled := true;
end;


procedure TfmEmployees.DBGrid1CellClick(Column: TColumn);
begin
  BtnUpdate.Enabled := true;
end;

procedure TfmEmployees.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if (gdSelected in State) then
  begin
     DBGrid1.Canvas.Font.Color := clWhite;
     DBGrid1.Canvas.Brush.Color := StringToColor('$00BE6414');
     DBGrid1.DefaultDrawColumnCell(Rect,DataCol,column,state);
  end;
end;

procedure TfmEmployees.FormCreate(Sender: TObject);
begin
  BtnUpdate.Enabled := false;
end;

procedure TfmEmployees.Timer1Timer(Sender: TObject);
begin
  Image1.Visible := false;
  LabelConfirmMessage.Visible := false;
  Timer1.Enabled := false;
end;

procedure TfmEmployees.BtnAddClick(Sender: TObject);
begin
  datasource1.DataSet.Append;
  BtnAdd.visible := false;
  BtnCancel.visible := true;
  BtnSave.visible := true;

end;

end.
