Attribute VB_Name = "Main"
Option Explicit

Private fLogLineNum As Long
Private fNumErrors As Long

Sub SaveTSVal(aBatch As OracleBulkExec, aTsId As Long, aDt As Date, aVal As Variant)
  Dim P1 As ADODB.Parameter, P2 As ADODB.Parameter, P3 As ADODB.Parameter, P4 As ADODB.Parameter
  Dim cm As New ADODB.Command
  
  Set P1 = cm.CreateParameter("P1", adVarChar, adParamInput, 1000, Environ$("Username"))
  Set P2 = cm.CreateParameter("P2", adNumeric, adParamInput, , aTsId)
  Set P3 = cm.CreateParameter("P2", adDate, adParamInput, , aDt)
  Set P4 = cm.CreateParameter("P2", adNumeric, adParamInput, , aVal)
  
  aBatch.AddRow P1, P2, P3, P4
End Sub

Sub ClearLog()
  Dim vAnchor As Range
  Set vAnchor = Range("OutpAnchor")
  Range(vAnchor, vAnchor.Offset(1000, 4)).Clear
  Range("OutpAnchor").Offset(-1).Resize(1, 4).Interior.Color = RGB(0, 50, 150)
  fLogLineNum = 0
End Sub

Sub AddLogImpl(ByVal aMsg As String, Optional ByVal aIsBold As Boolean = False _
  , Optional ByVal aIsEphemeral As Boolean = False)
  'Dim vOldScreenUpdating As Variant
  Application.ScreenUpdating = True
  Range("OutpAnchor").Offset(fLogLineNum).Value = aMsg
  If aIsBold Then Range("OutpAnchor").Offset(fLogLineNum).Font.Bold = True
  If Not aIsEphemeral Then fLogLineNum = fLogLineNum + 1
  DoEvents
End Sub

Sub AddLog(ByVal aMsg As String)
  AddLogImpl aMsg
End Sub

Sub AddBoldLog(ByVal aMsg As String)
  AddLogImpl aMsg, True
End Sub

Sub AddEphemeralLog(ByVal aMsg As String)
  AddLogImpl aMsg, , True
End Sub

Sub LogError(ByVal aMsg As String)
  Range("OutpAnchor").Offset(fLogLineNum).Value = aMsg
  Range("OutpAnchor").Offset(fLogLineNum).Interior.Color = RGB(255, 100, 100)
  Range("OutpAnchor").Offset(-1).Resize(1, 4).Interior.Color = RGB(255, 0, 0)
  fLogLineNum = fLogLineNum + 1
End Sub

Sub DieWithError(ByVal aMsg As String)
  LogError aMsg
  Err.Raise -1000, , aMsg
End Sub

Sub CollectError(ByVal aMsg As String)
  LogError aMsg
  fNumErrors = fNumErrors + 1
End Sub

Sub CheckCollectedErrors()
  If fNumErrors > 0 Then
    If fNumErrors = 1 Then
      Err.Raise -100, , "There was 1 error"
    Else
      Err.Raise -100, , "There were " & CStr(fNumErrors) & " errors"
    End If
  End If
End Sub

Sub LoadFromTS(aConn As PubEqCoreDBConnection, aTS As TSDataSheet)
  Dim vAssetClassStr As String
  Dim vFrequencyStr As String
  
  Dim vSeriesName As String
  Dim vInstrStr As String, vvInstr As Variant, vvInstId As Variant
  Dim vDt As Date
  Dim vVal As Variant
  Dim i As Long, j As Long
  Dim vInstId As Variant, vTsId As Long
  Dim vSql As String
  Dim vRecNo As Long, vBatchNo As Long
  vRecNo = 0
  
  Dim vBatch As New OracleBulkExec

  aTS.CleanseHdrNames
  vAssetClassStr = aTS.AssetClass
  vFrequencyStr = aTS.FrequencyStr
  
  vSql = "insert into arp.raw_ts_dtl(user_name, ts_hdr_id, dt, val) values (?,?,?,?)"
  vBatch.Init aConn.Conn, vSql, 4, 100, "AddEphemeralLog"
  
  AddEphemeralLog "Primig instrument IDs..."
  For Each vvInstr In aTS.InstrumentNames
     vvInstId = aConn.Cache.GetInstrumentId(aTS.AssetClass, vvInstr)
     If IsNull(vvInstId) Then CollectError "Instrument " & aTS.AssetClass & " '" & vvInstr & "' not found"
  Next vvInstr
  CheckCollectedErrors

  For i = 1 To aTS.RowCount
    For j = 1 To aTS.ColCount
      vVal = aTS.Val(i, j)
      If vVal <> "" Then
        vSeriesName = aTS.TimeSeriesName(i, j)
        vInstrStr = aTS.InstrName(i, j)
        vDt = aTS.Dt(i, j)
        vInstId = aConn.Cache.GetInstrumentId(aTS.AssetClass, vInstrStr)
        If IsNull(vInstId) Then DieWithError "Instrument " & aTS.AssetClass & " '" & vInstrStr & "' not found"
        vTsId = aConn.Cache.GetTimeSeriesId(True, vInstId, vSeriesName, vFrequencyStr)
        SaveTSVal vBatch, vTsId, vDt, aTS.Val(i, j)
        vRecNo = vRecNo + 1
      End If
    Next j
  Next i
  vBatch.FlushBuffer
  AddLog CStr(vBatch.RecCntUploaded) & " records uploaded"
  If vBatch.RecCntUploaded <> vRecNo Then DieWithError "Expecting " & vRecNo & " records"
End Sub

Sub BackupTimeSeries(aConn As PubEqCoreDBConnection)
  Dim vBkpId As Variant, vMsg As String
  vMsg = "Checking for recent backups..."
  AddEphemeralLog vMsg
  vBkpId = aConn.GetLastTodaysAppBackupId("TS")
  If IsNull(vBkpId) Then
    AddLog vMsg & " Was not backed up today."
    vMsg = "Backing up..."
    AddEphemeralLog vMsg
    vBkpId = aConn.NewTimeSeriesBkp
    ' aConn.Conn.CommitTrans
    AddLog vMsg & " Done. ID = " & CStr(vBkpId)
  Else
    AddLog vMsg & " Already backed up today, ID = " & CStr(vBkpId)
  End If
End Sub

Sub NewHFProc()
  Dim vRowNum As Long
  Dim vRow As Range
  Dim vAssetClass As String, vRapcName As String, vMgrName As String, vFundName As String
  Dim vStyleName As String, vRapcNum As Long, vAssetId As Variant, vOldASsetId As Variant
  
  For vRowNum = 1 To Range("RefData").Rows.Count
    Set vRow = Range("RefData").Rows(vRowNum)
    vOldASsetId = vRow.Cells(1, 1).Value
    vAssetClass = vRow.Cells(1, 2).Value
    vRapcName = vRow.Cells(1, 3).Value
    vMgrName = vRow.Cells(1, 4).Value
    vFundName = vRow.Cells(1, 5).Value
    vStyleName = vRow.Cells(1, 6).Value
    ' vRapcNum = vRow.Cells(1, 7).Value
    
    If vAssetClass = "" Or vRapcName = "" Then
      Exit Sub
    End If
    
    Dim vConn As New PubEqCoreDBConnection
    vAssetId = Empty
    If vAssetClass = "IDX" Then
      If IsEmpty(vOldASsetId) Then
        vAssetId = vConn.NewInstrument(vAssetClass, vRapcName)
      Else
        vAssetId = vConn.UpdInstrument(vOldASsetId, vRapcName)
      End If
    ElseIf vAssetClass = "HF" Then
      vAssetId = vConn.NewHedgeFund(vRapcName, vMgrName, vFundName, vStyleName)
    Else
      Err.Raise -1005, , "Invalid asset class: " & vAssetClass
    End If
    vRow.Cells(1, 1).Value = vAssetId
    
    
  Next vRowNum
End Sub

Sub LoadProc()
  fNumErrors = 0
  
  Dim vConn As New PubEqCoreDBConnection
  'Dim vInstId As Long
  'vInstId = vConn.GetInstrumentId("IDX", "MSCIworld")
  Dim vvRow As Variant
  Dim vRow As Range
  
  Dim vInputTabStr As String
  Dim vAnchorCellStr As String
  Dim vSeriesNameStr As String
  Dim vFrequencyStr As String
  Dim vAssetClassStr As String
  Dim vInstrumentStr As String
  Dim vDt As Date
  Dim vRowDim As TSDataHeaderType
  Dim vColDim As TSDataHeaderType
  
  Dim vLayerIdx As Long
  Dim vTS As TSDataSheet
  
  ClearLog
  BackupTimeSeries vConn
  
  vConn.DeleteRawTimeSeries
  AddBoldLog "Uploading..."
  
  ' For Each vvRow In Range("Config").Columns
  For vLayerIdx = 1 To Range("Config").Columns.Count
    Set vRow = Range("Config").Columns(vLayerIdx)
    
    vInputTabStr = vRow.Cells(1, 1).Value
    If vInputTabStr <> "" Then
      vAnchorCellStr = vRow.Cells(2, 1).Value
      vSeriesNameStr = vRow.Cells(3, 1).Value
      vFrequencyStr = vRow.Cells(4, 1).Value
      vAssetClassStr = vRow.Cells(5, 1).Value
      vInstrumentStr = vRow.Cells(6, 1).Value
      vDt = vRow.Cells(7, 1).Value
      vRowDim = StrToHeaderType(vRow.Cells(8, 1).Value)
      vColDim = StrToHeaderType(vRow.Cells(9, 1).Value)
      
      Set vTS = New TSDataSheet
      vTS.Initialize Range(vInputTabStr & "!" & vAnchorCellStr), vRowDim, vColDim
      vTS.FrequencyStr = vFrequencyStr
      vTS.AssetClass = vAssetClassStr
      vTS.SetTimeSeriesName (vSeriesNameStr)
      vTS.SetDt (vDt)
      vTS.SetInstrName (vInstrumentStr)
      'vTS.ColorForDebug
      'vTS.ClearColors
      AddBoldLog "-- " & vInputTabStr & " --"
      AddLog CStr(vTS.NonBlankCount) & " data points detected"
      LoadFromTS vConn, vTS
      'AddLog ""
    End If
    
  Next vLayerIdx
  
  Dim vRecsInserted As Long, vRecsUpdated As Long
  AddBoldLog "Applying updates..."
  vConn.ApplyRawTimeSeries vRecsInserted, vRecsUpdated
  AddLog CStr(vRecsInserted) & " rows inserted"
  AddLog CStr(vRecsUpdated) & " rows updated"
  
  'ts.SetTimeSeriesName(
End Sub
