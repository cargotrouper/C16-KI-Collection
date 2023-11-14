@A+
//===== Business-Control =================================================
//
//  Prozedur  Test+SQL
//                    OHNE E_R_G
//  Info      Erstellt zu den C16-Dateien passende Klassen für BC anhand
//            dem Config-Prozedurtext
//
//
//  21.11.2011  AI  Erstellung der Prozedur
//  11.06.2013  PW  LOGIC wird Bool
//  16.10.2020  AH  "Framework2Core" konvertiert Framework -> Core (PFADE SETZEN!!!!)
//
//  Subprozeduren
//    sub C16toCSharp(aText : alpha) : alpha;
//    sub Spezial1zu1(aDatei : int; aKey : int) : logic
//    sub SaveLOGIC(aDatei : int; aName : alpha; aPrefix : alpha; aText : int; aNameSpace : alpha) : logic
//    sub SaveSUBVIEW(aDatei : int; aName : alpha; aPrefix : alpha; aText : int; aNameSpace : alpha) : logic
//    sub SaveDEF(aDatei : int; aName : alpha; aPrefix : alpha; aText : int; aNameSpace : alpha) : logic
//    sub SaveQUERY(aDatei : int; aName : alpha; aPrefix : alpha; aText : int; aNameSpace : alpha; aConfigText : int) : logic
//
//  MAIN
//
//========================================================================

define begin
  cDbg_Filename     : 'd:\debug\debug.txt'
  cConfig_Proc      : 'test+SQL_txt'
  cPath             : 'd:\C16_Export'   // + Core\Date
  cAutoSync         : false             // Annotation

  cTestDatei        : 000

  cTest             : false             // nur Datei 100 und 800
  cSatzEnde         : Strchar(13)+Strchar(10)
  cTab              : StrChar(9)
  cTrans            : '"'

  Str_Token(a,b,c)  : Lib_Strings:Strings_Token(a,b,c)
  AInt(a)           : CnvAI(a,_FmtNumNoGroup)
  TextAddLine(a,b)  : TextLineWrite(a,TextInfo(a,_TextLines)+1,b,_TextLineInsert)
  Write(a)          : begin vOut # Lib_Strings:Strings_Dos2Win(a,n);  FsiWrite(vFile,vOut); end
  WriteLN(a)        : begin vOut # Lib_Strings:Strings_Dos2Win(a+cSatzEnde,n);  FsiWrite(vFile,vOut); end
  WriteERROR(a)     : begin vOut # Lib_Strings:Strings_Dos2Win(a+cSatzEnde,n);  FsiWrite(vFile,vOut); debug(a); end
  DebugX(a)         : Debug(a+'   ['+__PROC__+':'+aint(__LINE__)+']')
end;


//========================================================================
//========================================================================

//========================================================================
//  Debug
//        Schreibt in externe Debugdatei
//========================================================================
sub Debug(
  aText : alpha(2000);
)
local begin
  vFile : int;
  vX    : int;
end;
begin
  aText # aText + strchar(13) + strchar(10);
  vFile # FSIOpen(cdbg_FileName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
  if (vFile>0) then begin
    FsiWrite(vFile, aText);
    FsiClose(vFile);
  end;
end;


//========================================================================
//  myInitDebug
//
//========================================================================
sub myInitDebug()
begin
  Fsidelete(cDbg_Filename)
end;


//========================================================================
//========================================================================
sub PutText(
  aTxt    : int;
  var aZ  : int;
  aBla    : alpha(250))
begin
  TextLineWrite(aTxt, aZ, aBla, _TextLineInsert);
  inc(aZ);
end;


//========================================================================
sub _Framework2CoreSub(
  aFrameDir   : alpha(1000);
  aCoreDir    : alpha(1000);
  aMatch      : alpha;
  aNameSpace  : alpha;
)
local begin
  vName     : alpha(1000);
  vA        : alpha(4000);
  vDir      : int;
  vTxt      : int;
  vI,vJ,vZ  : int;
end;
begin
  vTxt # TextOpen(20);

  vDir # FsiDirOpen(aFrameDir + '\' + aMatch, _FsiNameUtf8);
  vName # vDir->FsiDirRead();
  WHILE (vName != '') do begin

    TextClear(vTxt);
    TextRead(vTxt, aFramedir+'\'+vName, _TextExtern);
    
    vI # TextSearch(vTxt, 1, 1, _TextSearchCI, 'namespace BC.Server.Service.Report.'+aNameSpace);
    if (vI<>0) then begin
      vJ # TextSearch(vTxt, 1, 1, _TextSearchCI, '// STAHLCONTROL');
      if (vJ=1) then begin
        vA # TextLineRead(vTxt, vJ , _TextLineDelete);
        vI # TextSearch(vTxt, 1, 1, _TextSearchCI, 'namespace BC.Server.Service.Report.'+aNameSpace);
      end;

      vJ # TextSearch(vTxt, 1, 1, _TextSearchCI, 'using ');
      // z.B. 15 - 7 = 8

      FOR vZ # vJ
      LOOP inc(vZ)
      WHILE (vZ<=vI) do begin
        vA # TextLineRead(vTxt, vJ , _TextLineDelete);
      END;
      if (vJ=1) then
        PutText(vTxt, var vJ, '// STAHLCONTROL (NetCore) 16.10.2020');
      PutText(vTxt, var vJ, 'using System;');
      PutText(vTxt, var vJ, 'using System.Linq;');
      PutText(vTxt, var vJ, 'using BC.Server.BO;');
      PutText(vTxt, var vJ, 'using BC.Util;');
      PutText(vTxt, var vJ, 'using System.Collections.Generic;');
      PutText(vTxt, var vJ, 'using System.IO;');
      PutText(vTxt, var vJ, 'using BC.Server.Reporting.Forms;');
      PutText(vTxt, var vJ, 'using static BC.Server.Reporting.Generator;');
      PutText(vTxt, var vJ, 'using System.Text.RegularExpressions;');
      PutText(vTxt, var vJ, 'using System.Linq.Expressions;');
      PutText(vTxt, var vJ, 'using BC.Server.BusinessLogic.BusinessObjects;');
      if (vName='Rechnung.cs') then
        PutText(vTxt, var vJ, 'using ZF = s2industries.ZUGFeRD;');
      PutText(vTxt, var vJ, '');
      PutText(vTxt, var vJ, 'namespace BC.Server.Reporting.'+aNameSpace);
    end;
    
//TextWrite(vTxt, '', _TextClipboard);
    vA # aCoreDir+'\'+vName;
    FsiDelete(vA);
    TextWrite(vTxt, vA, _textExtern);
    
    vName # vDir->FsiDirRead();
  END;

  vDir->FsiDirClose();
  TextClose(vTxt);
end;


//========================================================================
//========================================================================
sub Framework2Core()
begin
  _FrameWork2CoreSub(
      'C:\BCS_Source\BC_Full\Server\Services\BC.Server.Service.ReportService\Reports',
      'C:\BC_Core\Server\Reporting\Reports',
      '*.cs', 'Reports');

  _FrameWork2CoreSub(
      'C:\BCS_Source\BC_Full\Server\Services\BC.Server.Service.ReportService',
      'C:\BC_Core\Server\Reporting\DTOs',
      'DTOs*.*', 'Forms');
    
  _FrameWork2CoreSub(
      'C:\BCS_Source\BC_Full\Server\Services\BC.Server.Service.ReportService\Forms',
      'C:\BC_Core\Server\Reporting\Forms',
      '*.cs', 'Forms');

end;


//========================================================================
//  Tokenline
//
//========================================================================
sub TokenLine(
  aLine       : alpha;
  var aDatei  : int;
  var aName   : alpha;
  var aPrefix : alpha)
local begin
  vB  : alpha;
end;
begin
  vB # StrAdj(Str_Token(aLine,'|',1), _StrBegin|_StrEnd);
  aDatei # cnvia(vB);
  vB # StrAdj(Str_Token(aLine,'|',2), _StrBegin|_StrEnd);
  aName # vB;
  vB # StrAdj(Str_Token(aLine,'|',3), _StrBegin|_StrEnd);
  aPrefix # vB;
end;


//========================================================================
//========================================================================
sub C16toCSharp(
  aText   : alpha;
  aPrefix : alpha;
) : alpha;
local begin
  vI    : int;

end;
begin

  // für die Ablagen
//  aText # Lib_strings:Strings_ReplaceAll(aText, '~', '_');

  if (aPrefix<>'') then begin
    if (StrFind(StrCnv(aText,_StrUpper),StrCnv(aPrefix,_StrUpper),0)=1) then begin
      aText # StrCut(aText, StrLen(aPrefix)+1, 50);
    end;
  end;


  aText # Lib_strings:Strings_ReplaceAll(aText, '$', 'Dollar');
  aText # Lib_strings:Strings_ReplaceAll(aText, '%', 'Prozent');
  aText # Lib_strings:Strings_ReplaceAll(aText, '\', 'Pro');

  aText # Lib_strings:Strings_ReplaceAll(aText, 'Username', 'Superhorst');
  aText # Lib_strings:Strings_ReplaceAll(aText, 'User', 'Superhorst');
  aText # Lib_strings:Strings_ReplaceAll(aText, 'Superhorst', 'Username');

  aText # Lib_strings:Strings_ReplaceAll(aText, 'ä', 'ae');
  aText # Lib_strings:Strings_ReplaceAll(aText, 'ö', 'oe');
  aText # Lib_strings:Strings_ReplaceAll(aText, 'ü', 'ue');
  aText # Lib_strings:Strings_ReplaceAll(aText, 'Ä', 'Ae');
  aText # Lib_strings:Strings_ReplaceAll(aText, 'Ö', 'Oe');
  aText # Lib_strings:Strings_ReplaceAll(aText, 'Ü', 'Ue');
  aText # Lib_strings:Strings_ReplaceAll(aText, 'ß', 'ss');//strchar(195)+strchar(159));
//  aText # Lib_strings:Strings_ReplaceAll(aText, '€', strchar(226)+strchar(130)+strchar(172));

//  aText # Lib_strings:Strings_ReplaceAll(aText, 'µ', strchar(194)+strchar(181));

//  aText # Lib_strings:Strings_ReplaceAll(aText, '&', StrChar(254)+'amp;');
//  aText # Lib_strings:Strings_ReplaceAll(aText, StrChar(254), '&');
//  aText # Lib_strings:Strings_ReplaceAll(aText, '<', '&lt;');
//  aText # Lib_strings:Strings_ReplaceAll(aText, '>', '&gt;');

  aText # Lib_strings:Strings_ReplaceAll(aText, '.', '_');
  aText # Lib_strings:Strings_ReplaceAll(aText, '-', '_');
  aText # Lib_strings:Strings_ReplaceAll(aText, '!', 'Nicht');


  RETURN aText;
end;


//========================================================================
//  Spezial1zu1
//              Erkennt nicht-neindeutige Schlüssel als doch eindeutig
//========================================================================
sub Spezial1zu1(
  aDatei  : int;
  aKey    : int) : logic
begin

  // STAHLCONTROL-Adressdatei ist immer eindeutig
  if (aDatei=100) and ((aKey=1) or (aKey=2) or (aKey=3)) then RETURN true;

  RETURN false;
end;


//========================================================================
//  SaveFIELDS
//
//========================================================================
sub SaveFIELDS(
  aText       : int) : logic
local begin
  vOut        : alpha(2540);
  vFile       : int;
  vI          : int;
  vA          : alpha(1000);
  vTName      : alpha;
  vFName      : alpha;
end;
begin
/***
using System;

namespace BC.Core.Data
{
	public class Fields
	{
		public enum Adr_Anschrift
		{
			Adressnr,
			Nummer,
			Stichwort,
			Anrede,
			Name,
			Zusatz,
			Strasse,
			LKZ,
			PLZ,
			Ort,
			Telefon,
			Telefax,
			eMail,
			Vertreter,
			Tour,
			EntfernungKm,
			LagergeldTTag,
			Warenannahme1,
			Warenannahme2,
			Warenannahme3,
			Warenannahme4,
			Warenannahme5,
			Betriebsferien
		}
		...
	}
}
***/
  vFile # FSIOpen(cPath+'\Core\Data\EnumFields.generated.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  /* Dateinamen schreiben */
  WriteLN('// autogenerated by C16 on '+cnvad(Sysdate()));
  //WriteLN('using System;');
  //WriteLN('');
  WriteLN('namespace BC.Core.Data');
  WriteLN('{');
  WriteLN(cTab+'public partial class Fields');
  WriteLN(cTab+'{');

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=TextInfo(aText,_TextLines)) do begin

    vA # TextLineRead(aText, vI,0);
    if (StrCut(vA,1,5)='F_ALT') then begin
      if (vFName<>'') then
        WriteLN(cTab+cTab+cTab+vFName+',');

      vFName # Str_Token(vA,'|',2);
    end;

    if (StrCut(vA,1,5)='T_ALT') then begin
      if (vFName<>'') then
        WriteLN(cTab+cTab+cTab+vFName);
      vFName # '';
      if (vTName<>'') then begin
        WriteLN(cTab+cTab+'}');
        WriteLN('');
      end;
      vTName  # Str_Token(vA,'|',3);  // OBJ-Namen holen
      WriteLN(cTab+cTab+'public enum '+vTName);
      WriteLN(cTab+cTab+'{');
      vFName # '';
    end;
  END;
  if (vFName<>'') then
    WriteLN(cTab+cTab+cTab+vFName+'');

  WriteLN(cTab+cTab+'}');

  WriteLN(cTab+'}');
  WriteLN('}');

  FSIClose(vFile);

  RETURN true;
end;


//========================================================================
//  SaveLOGIC
//
//========================================================================
sub SaveLOGIC(
  aDatei      : int;
  aName       : alpha;
  aPrefix     : alpha;
  aText       : int;
  aNameSpace  : alpha) : logic
local begin
  vOut        : alpha(2540);
  vFile       : int;
end;
begin

  vFile # FSIOpen(cPath+'\BLOs\'+aNamespace+'\'+aName+'_Logic.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  /* Dateinamen schreiben */
  WriteLN('// autogenerated by C16 on '+cnvad(Sysdate()));
  WriteLN('using BC.Server.BusinessLogic.ORM;');
//  WriteLN('using BC.Code.Date;');
  WriteLN('using CO = BC.Core.Data;');
  WriteLN('using Fields = BC.Core.Data.Fields;');
  WriteLN('');
//  WriteLN('namespace BC.BusinessLogic.'+aNameSpace);
  WriteLN('namespace BC.Server.BO');
  WriteLN('{');
  WriteLN(cTab+'public partial class '+aName+' : CO.'+aName+', IDbRecord');
  WriteLN(cTab+'{');
  WriteLN('');

  WriteLN(cTab+'}'+cTab+'// '+aName);
  WriteLN('}');
  WriteLN('');

  FSIClose(vFile);

  RETURN true;
end;


//========================================================================
//  SaveSUBVIEW
//
//========================================================================
sub SaveSUBVIEW(
  aDatei      : int;
  aName       : alpha;
  aPrefix     : alpha;
  aText       : int;
  aNameSpace  : alpha) : logic
local begin
  vOut        : alpha(2540);
  vFile       : int;
end;
begin
/***
// autogenerated by C16 on 123456
using BC.Server.BusinessLogic.ORM;
using BC.Core.Data;
using Fields = BC.Core.Data.Fields;

namespace BC.Server.BO
{
	public partial class Adresse : BC.Core.Data.Adresse, IDbRecord
	{
	}	// Adresse
}
***/
	
  vFile # FSIOpen(cPath+'\'+aNamespace+'\'+aName+'_Subview.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  /* Dateinamen schreiben */
  WriteLN('// autogenerated by C16 on '+cnvad(Sysdate()));
  WriteLN('using System;');
  WriteLN('using BC.Server.BusinessLogic.ORM;');
  WriteLN('using CO = BC.Core.Data;');
  WriteLN('using Fields = BC.Core.Data.Fields;');
  WriteLN('');
//  WriteLN('namespace BC.BusinessLogic.'+aNameSpace);
  WriteLN('namespace BC.Server.BO');//+aNameSpace);
  WriteLN('{');
  WriteLN(cTab+'public partial class '+aName+' : CO.'+aName+', IDbRecord');
  WriteLN(cTab+'{');
  WriteLN('');
  WriteLN(cTab+'}'+cTab+'// '+aName);
  WriteLN('}');
  WriteLN('');

  FSIClose(vFile);

  RETURN true;
end;


//========================================================================
//  SaveDEF
//
//========================================================================
sub SaveDEF(
  aDatei      : int;
  aName       : alpha;
  aPrefix     : alpha;
  aText       : int;
  aNameSpace  : alpha) : logic;
local begin
  vName     : alpha;
  vNewName  : alpha;
  vTyp      : alpha;
  vMaxTds   : int;
  vMaxFld   : int;
  vTds      : int;
  vFld      : int;
  vFirst    : logic;
  vHdl      : int;
  vOut      : alpha(2540);
  vA,vB     : alpha(254);
  vFile     : int;
  vI,vJ     : int;
  vKeyA     : alpha(250);
  vSpez     : logic;
end;
begin

  vFile # FSIOpen(cPath+'\Core\Data\'+aNameSpace+'\'+aName+'.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  vName     # Filename(aDatei);
  vNewName # aName;
  TextAddLine(aText, 'T_ALT'+aint(aDatei)+'|'+vNewName+'|'+aName);

  /* Dateinamen schreiben */
  WriteLN('// autogenerated by C16 on '+cnvad(Sysdate()));
  WriteLN('using System;');
  WriteLN('');
  WriteLN('namespace BC.Core.Data');
  WriteLN('{');

  if (cAutoSync) then WriteLN(cTab+'[DbAutoSync]');
  WriteLN(cTab+'[PetaPoco.Attributes.TableName("'+vNewName+'")]');


  // PRIMARY KEY ***************************************************
  vA # '';
  vJ # KeyInfo(aDatei, 1, _KeyFldCount);
  vKeyA # '|';
  FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
    vFld # KeyFldInfo(aDatei,1,vI,_KeyFldNumber);
    vTds # KeyFldInfo(aDatei,1, vI, _KeyFldSbrNumber);
    if (vA<>'') then vA # vA + ', ';
    vB # FldName(aDatei, vTds, vFld);
    vB # C16toCSharp(vB, aPrefix);
    vA # vA + vB;
    vKeyA # vKeyA + aint(vFld)+'|';
  END;
  WriteLN(cTab+'[DbPrimaryKey("'+vA+'")]');


  // CLASS PROPERIES ***********************************************
  WriteLN(cTab+'public class '+aName+' : DbRecord');
  WriteLN(cTab+'{');


  // FELDER loopen...
  vMaxTds   # FileInfo(aDatei,_FileSbrCount);
  vFirst # y;
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      vFirst # n;

      vA # FldName(aDatei,vTds,vFld);

//      vSpez # (vA='Prj.P.Anlage.Datum');

      if (StrFind(StrCnv(vA,_StrUpper),StrCnv(aPrefix,_StrUpper),0)=1) then begin
      end
      else begin
Debug('bitte prüfen:'+aint(aDatei)+' '+vA);
        CYCLE;
      end;

      if (vSpez=false) and (
         (StrFind(vA,'Anlage.Zei',0)>0) or
          (StrFind(vA,'Anlage.Use',0)>0) or
          (StrFind(vA,'Anlage.Dat',0)>0) or
          (StrFind(vA,'Änderung.Zeit',0)>0) or
          (StrFind(vA,'Änderung.User',0)>0) or
          (StrFind(vA,'Änderung.Datum',0)>0) or
          (StrFind(vA,'Lösch.Zeit',0)>0) or
//          (StrFind(vA,'Lösch.Grund',0)>0) or
          (StrFind(vA,'Lösch.User',0)>0) or
          (StrFind(vA,'Lösch.Datum',0)>0)) then begin
        CYCLE;
      end;

      case FldInfo(aDatei,vTds,vFld,_FldType) of
        _TypeAlpha  : begin
          WriteLN(cTab+cTab+'[DbMaxLength('+cnvai(FldInfo(aDatei,vTds,vFld,_FldLen))+')]');
          vTyp # 'string';
          end;
        _typeWord   : vTyp # 'int';   // war int16
        _typeInt    : vTyp # 'int';
        _typeFloat  : vTyp # 'double'; // float??
        _typeLogic  : vTyp # 'bool';
        _typeDate   : vTyp # 'DateTime';
        _typeTime   : vTyp # 'DateTime';
        otherwise vTyp # 'ERROR';
      end;

      // not null weil Primary Key?
      if (vTds=1) and (StrFind(vKeyA,'|'+aint(vFld)+'|',0)>0) then begin
        WriteLN(cTab+cTab+'[DbNotNull]');
      end
      // wenn nicht NotNull, dann möglichweise nullable value type
      else if (vTyp = 'DateTime') then begin
        vTyp # vTyp + '?';
      end

      vB # C16toCSharp(vA, aPrefix);
TextAddLine(aText, 'F_ALT'+vA+'|'+vB+'|'+vTyp+'|File:'+aint(aDatei));
      vA # 'public virtual '+vTyp+' '+vB;



      WriteLN(cTab+cTab + vA);
      WriteLN(cTab+cTab + '{ get; set; }');

    END;
  END;

/***
  WriteLN('');
  WriteLN(cTab+cTab+'public '+vNewName+'()');
  WriteLN(cTab+cTab+'{');

  // FELDER loopen...
  vMaxTds   # FileInfo(aDatei,_FileSbrCount);
  vFirst # y;
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      vA # FldName(aDatei,vTds,vFld);
      if (StrFind(StrCnv(vA,_StrUpper),StrCnv(aPrefix,_StrUpper),0)=1) then begin
        end
      else begin
        CYCLE;
      end;
      if (StrFind(vA,'Anlage.Zeit',0)>0) or
          (StrFind(vA,'Anlage.User',0)>0) or
          (StrFind(vA,'Anlage.Datum',0)>0) or
          (StrFind(vA,'Änderung.Zeit',0)>0) or
          (StrFind(vA,'Änderung.User',0)>0) or
          (StrFind(vA,'Änderung.Datum',0)>0) or
          (StrFind(vA,'Lösch.Zeit',0)>0) or
//          (StrFind(vA,'Lösch.Grund',0)>0) or
          (StrFind(vA,'Lösch.User',0)>0) or
          (StrFind(vA,'Lösch.Datum',0)>0) then begin
        CYCLE;
      end;
      case FldInfo(aDatei,vTds,vFld,_FldType) of
        _TypeDate, _TypeTime   : begin
          vB # C16toCSharp(vA, aPrefix);
          if (vFirst) then
            WriteLN(cTab+cTab+cTab+'DataTime firstDayInSystem = new DateTime(1900,1,1,12,0,0);');
          WriteLN(cTab+cTab+cTab+'this.'+vB+' = First DayInSystem;');
          vFirst # n;
        end;
        otherwise CYCLE;
      end;
    END;
  END;
  WriteLN(cTab+cTab+'}');
****/

//        public Adresse()
//        {
//            DateTime firstDayInSystem = new DateTime(1900,1,1,12,0,0);
//            this.EK_ZertifikatBis   = firstDayInSystem;
//        }
  // 3 Tabs = 12 Zeichen
  // 123 = 0 = 3T
  // 1 = 0 = 3T
  // 1234 = 1 = 2T
  // 12345 = 1 = 2T
  // 12345678 = 2 = 1T
  // 123456789 = 2 =1T

  WriteLN(cTab+'}');
  WriteLN('}');

  FSIClose(vFile);

  RETURN true;
end;



//========================================================================
//
//========================================================================
Sub WriteCustomAttribs(
  aFile     : int;
  aText     : int;
  aDatei    : int;
  aIndex    : int;
  a2Datei   : int;
  a2Key     : int;
  aName1    : alpha;
  aName2    : alpha;
  );
local begin
  vI        : int;
  vTds      : int;
  vFld      : int;
  vFName    : alpha;
  vK, vJ    : int;
  vOut      : alpha(2540);
  vNewFName : alpha;
  vNew2FName : alpha;
  vFile     : int;
  vA, vB    : alpha(4095);
  vSQL      : alpha(4000);
  v2FName   : alpha;
  vFTyp     : int;
end;
begin
  vFile # aFile;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=LinkInfo(aDatei, aIndex, _LinkFldCount)) DO BEGIN
    vTds # LinkFldInfo(aDatei, aIndex, vI, _LinkFldSbrNumber);
    vFld # LinkFldInfo(aDatei, aIndex, vI, _LinkFldNumber);

    vFName # FldName(aDatei, vTds, vFld);
    vK # TextSearch(aText, 1,1, 0, 'F_ALT'+vFName+'|');
    if (vK=0) then begin
WriteERROR('Datei '+aint(aDatei)+': FEHLENDES FELD: '+vFName);
      CYCLE;
    end;
    vA # TextLineRead(aText, vK,0);
    vNewFName # Str_Token(vA,'|',2);
//debug('VON '+aint(aDatei)+'/'+aint(aIndex)+' -> '+aint(a2Datei)+'/'+aint(a2Key)+'/'+aint(vI));
    vK # KeyFldInfo(a2Datei, a2Key, vI, _KeyFldSbrNumber);
    vJ # KeyFldInfo(a2Datei, a2Key, vI, _KeyFldNumber);
    v2FName # FldName(a2Datei, vK, vJ);
    vFTyp   # FldInfo(a2Datei, vK, vJ, _FldType);

    vK # TextSearch(aText, 1,1, 0, 'F_ALT'+v2FName+'|');
    if (vK=0) then begin
WriteERROR('Datei '+aint(aDatei)+': FEHLENDES FELD: '+v2FName);
      CYCLE;
    end;
    vA # TextLineRead(aText, vK,0);
    vNew2FName # Str_Token(vA,'|',2);

    if (vB != '') then vB # vB + ',';
    vB # vB + '"' + vNewFName+ '"';

    if (vSQL != '') then vSQL # vSQL + '|';
//    vSQL # vSQL + aName1+'.'+vNewFName + '=' + aName2+'.'+vNew2FName;
    vSQL # vSQL + vNew2FName + '=' + vNewFName;
  END;


// OBSOLETE  WriteLN(cTab+cTab+'[CO.NeededFields('+vB+')]');

// OBSOLETE  WriteLN(cTab+cTab+'[CO.SqlJoins("'+aName2+'")]');
  vJ # Lib_Strings:Strings_Count(vSQL,'|');
  FOR vI # 1;
  LOOP inc(vI)
  WHILE (vI<=vJ+1) do begin

    vA # Str_Token(vSql,'|',vI);
    if (vI=1) and (vJ=0) then
      WriteLN(cTab+cTab+'[CO.SqlLink("'+vA+'")]')
    else if (vI=1) then
      WriteLN(cTab+cTab+'[CO.SqlLink("'+vA+'",')
    else if (vI<vJ+1) then
      WriteLN(cTab+cTab+cTab+'"'+vA+'",');
    else
      WriteLN(cTab+cTab+cTab+'"'+vA+'")]');
  END;

/**
SELECT TOP 130
      Material.Nummer
      ,Material.Guete
	  ,Material.Dicke
	  ,Warengruppe.Bezeichnung_L1

  FROM [SYNC_EntwicklungNET].[dbo].[Material]

  LEFT JOIN [SYNC_EntwicklungNET].[dbo].[Warengruppe]
  ON Material.Warengruppe = Warengruppe.Nummer

  WHERE Material.Dicke>900;


SELECT TOP 15 RowNr, Nummer, Teil
FROM (
SELECT ROW_NUMBER() OVER
(ORDER BY Material.Nummer, Material.RecId) AS RowNr,
Material.Nummer,
Material.RecId ,
GetLieferant.Stichwort as Teil
FROM [SYNC_EntwicklungNET].[dbo].[Material]

	LEFT JOIN [SYNC_EntwicklungNET].[dbo].[Adresse] as GetLieferant
	ON Material.Lieferant = GetLieferant.LieferantenNr AND Material.Lieferant > 0
)
sub
WHERE Teil > 'DA' ORDER BY Teil, RecId;


/**WHERE Nummer >= 1015 ORDER BY Nummer, RecId;**/

/**
SELECT TOP 1 RowNr
FROM (SELECT ROW_NUMBER() OVER
(ORDER BY Nummer, RecId) AS RowNr, Nummer, RecId FROM [SYNC_EntwicklungNET].[dbo].[Material])
sub WHERE Nummer >= 1015 ORDER BY Nummer, RecId;
**/

**/

end;


//========================================================================
//  SaveQUERY
//
//========================================================================
sub SaveQUERY(
  aDatei      : int;
  aName       : alpha;
  aPrefix     : alpha;
  aText       : int;
  aNameSpace  : alpha;
  aConfigTxt  : int;
) : logic
local begin
  vTName      : alpha;
  vNew2TName  : alpha;

  vOut        : alpha(2540);
  vFile       : int;
  vI,vJ       : int;
  vK,vL       : int;
  vA,vB,vC    : alpha(2540);
  vB2         : alphA(2540);

  v2Datei     : int;
  vIndex      : int;
  vTds, vFld  : int;
  vFName      : alpha;
  vNewFName   : alpha;
  v2Key       : int;
  v2FName     : alpha;
  vNew2FName  : alpha;
  v1zu1       : logic;
  vTyp        : alpha;
  vFTyp       : int;
  //vString     : alpha(200);
  //vIsSTring   : logic;
  vObj2Name   : alpha;
  vFirst      : alpha(500);
  vSecond     : alpha(300);
end;
begin
	
  vFile # FSIOpen(cPath+'\BO\'+aNameSpace+'\'+aName+'.generated.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  vTName # C16toCSharp(Filename(aDatei), aPrefix);

  /* Dateinamen schreiben */
  WriteLN('// autogenerated by C16 on '+cnvad(Sysdate()));
  WriteLN('using BC.Server.BusinessLogic;');
  WriteLN('using System;');
  WriteLN('using System.Collections.Generic;');
  WriteLN('using System.Linq.Expressions;');
  WriteLN('using CO = BC.Core.Data;');
  //WriteLN('using Fields = BC.Core.Data.Fields;');
  WriteLN('');
  WriteLN('namespace BC.Server.BO');
  WriteLN('{');
  WriteLN(cTab+'public partial class '+aName+' : CO.'+aName+', IDbRecord');
  WriteLN(cTab+'{');

  // Konstruktoren aus CO.Data *************************************
  WriteLN(cTab+cTab+'public '+aName+'()');
  WriteLN(cTab+cTab+'{ }');
  WriteLN('');
  WriteLN('');
  WriteLN(cTab+cTab+'public '+aName+'(CO.'+aName+' '+StrCnv(aName,_Strlower)+')');
  WriteLN(cTab+cTab+'{');
  WriteLN(cTab+cTab+cTab+'Util.Utils.CopyProperties('+StrCnv(aName,_strLower)+', this);');
  WriteLN(cTab+cTab+'}');
  WriteLN('');
  WriteLN('');


  // PRIMARY KEY ***************************************************
  vB # '';
  vC # '';

  vJ # KeyInfo(aDatei, 1, _KeyFldCount);
  FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
    vFld # KeyFldInfo(aDatei,1,vI,_KeyFldNumber);
    vTds # KeyFldInfo(aDatei,1, vI, _KeyFldSbrNumber);

    vFName # FldName(aDatei, vTds, vFld);

    vK # TextSearch(aText, 1,1, 0, 'F_ALT'+vFName+'|');
    if (vK=0) then begin
WriteERROR('Datei '+aint(aDatei)+': FEHLENDES FELD: '+vFName);
      CYCLE;
    end;
    vA # TextLineRead(aText, vK,0);
    vNewFName # Str_Token(vA,'|',2);
    vTyp # Str_Token(vA,'|',3);

//    vIsString # n;
//    if (FldInfo(aDatei,vTds,vFld,_FldType)=_Typealpha) then begin
//      vString # vString + 'Database.SafeSQL(ref a'+vNewFName+');';
//      vIsString # y;
//    end;

    // method parameters
    if (vB<>'') then vB # vB + ', ';
    vB # vB + vTyp+' '+'a'+vNewFName;

    // lambda expression
    if (vC != '') then vC # vC + ' && ';
    vC # vC + 'o.' + vNewFName + ' == a' + vNewFName;
  END;

  WriteLN(cTab+cTab+'public static ' + aName + ' Get(IDatabase db, ' + vB + ')');
  WriteLN(cTab+cTab+'{');
  WriteLN(cTab+cTab+cTab+'return db.SingleOrDefault<'+aName+'>(o => ' + vC + ');');
  WriteLN(cTab+cTab+'}');
  WriteLN('');

  // Verknüpfungen loopen ------------------------------------------------------------------

  FOR vIndex # 1 loop inc(vIndex) WHILE (LinkInfo(aDatei, vIndex, _LinkExists)>0) do begin

    if (StrLen(LinkName(aDatei,vIndex))<=3) then begin
Debug('Verknüpfung '+aint(aDatei)+' '+aint(vIndex)+' uebersprungen!');
      CYCLE;
    end;
    // Zieldatei ermitteln...
    v2Datei # LinkInfo(aDatei, vIndex,_LinkDestFileNumber);
    vK # TextSearch(aText, 1,1, 0, 'T_ALT'+aint(v2Datei));
    if (vK=0) then begin
//WriteERROR('//Datei '+aint(aDatei)+' fehlender Link nach: '+aint(v2Datei));
      CYCLE;
    end;
    vA # TextLineRead(aText, vK,0);
    vNew2TName  # Str_Token(vA,'|',2);
    vObj2Name   # Str_Token(vA,'|',3);


    // ZielKey ermitteln...
    v2Key # LinkInfo(aDatei, vIndex, _LinkDestKeyNumber);

    v1zu1 # n;
    if (KeyInfo(v2Datei, v2Key, _KeyFldCount) = Linkinfo(aDatei, vIndex, _LinkFldCount)) and
        (KeyInfo(v2Datei, v2Key, _KeyIsUnique)=1) then v1zu1 # y;
    v1zu1 # v1zu1 or Spezial1zu1(v2Datei, v2Key);


    vB # LinkName(aDatei, vIndex);
    vB # Str_Token(vB,'>',2);
    if (vB='') then begin
Debug('Verknüpfung '+aint(aDatei)+' '+aint(vIndex)+' hat komischen Namen:'+LinkName(aDatei, vIndex));
      vB # vNew2TName;
      end
    else begin
      vB # C16toCSharp(vB, '');
      vB # Lib_strings:Strings_ReplaceAll(vB, '_', '');
      vB # Lib_strings:Strings_ReplaceAll(vB, '~', 'Ablage');
    end;

//debug('prüfe '+vB+': '+aint(aDatei)+'/'+aint(vIndex)+' -> '+aint(v2Datei)+'/'+aint(v2Key));
//debug(aint(KeyInfo(v2Datei, v2Key, _KeyFldCount)) +' <- '+aint(Linkinfo(aDatei, vIndex, _LinkFldCount)));
//debug(aint(KeyInfo(v2Datei, v2Key, _KeyIsUnique)));

    if (v1zu1) then begin
      WriteLN('');
      WriteLN(cTab+cTab + '/// <summary>');
      WriteLN(cTab+cTab + '/// Get ' + vB + '.');
      WriteLN(cTab+cTab + '/// </summary>');
      WriteLN(cTab+cTab + '/// <param name="db">Database connection.</param>');
      WriteLN(cTab+cTab + '/// <returns>' + vB + '.</returns>');

      // für Lazy-Loading...
      // erstes Zeichen GROSS wandeln
      vB # StrCnv(StrCut(vB,1,1),_strUpper)+StrCut(vB,2,1000);

      // erstes Zeichen KLEIN schreiben
      vB2 # StrCnv(StrCut(vB,1,1),_strlower)+StrCut(vB,2,1000);
/***
      // PRIVATE FIELD:
      WriteLN(cTab+cTab+'private '+vObj2Name+' '+vB2+'Obj;');
      WriteLN(cTab+cTab+'[DbIgnore]');
      // erstes Zeichen KLEIN schreiben

      // PROPERTY:
      // erstes Zeichen GROSS schreiben
      WriteLN(cTab+cTab+'public '+vObj2Name+' '+vB+'Obj');
      WriteLN(cTab+cTab+cTab+'{');
      WriteLN(cTab+cTab+cTab+cTab+'get {');
      WriteLN(cTab+cTab+cTab+cTab+cTab+'if ('+vB2+'Obj == null)');
      WriteLN(cTab+cTab+cTab+cTab+cTab+cTab+vB2+'Obj = Get'+vB+'();');
      WriteLN(cTab+cTab+cTab+cTab+'return '+vB2+'Obj;');
      WriteLN(cTab+cTab+cTab+'}');
      WriteLN(cTab+cTab+'}');
***/

      // METHODE:
      //WriteLN(cTab+cTab+'private '+vObj2Name+' Get'+vB+'()');
// 01.12.2015:

      WriteCustomAttribs(vFile, aText, aDatei, vIndex, v2Datei, v2Key, aName, vObj2Name);

      WriteLN(cTab+cTab+'public '+vObj2Name+' Get'+vB+'(IDatabase db)');
      WriteLN(cTab+cTab+'{');
    end
    else begin
      vI # TextSearch(aConfigTxt, 1,1,0, 'MULTILINK '+aint(aDatei)+' '+cnvai(vIndex,0,0,2)+':');
      if (vI=0) then begin
Debug('fehlt: MULTILINK '+aint(aDatei)+' '+cnvai(vIndex,0,0,2)+':'+vB);
          CYCLE;
        end
      else begin
        vB # TextLineRead(aConfigTxt, vI, 0);
        vB # Str_token(vB,':',2);
        if (StrLen(vB)<3) then begin
Debug('Verknüpfung '+vB+' übersprungen bei '+aint(aDatei));
          CYCLE;
        end;
      end;
//Debug('MULTILINK '+aint(aDatei)+' '+cnvai(vIndex,0,0,2)+':'+vB);

      if (LinkName(aDatei, vIndex) = 'Art.C->Auf.Aktionen') then
        vA # vA + '';

      WriteLN('');
      WriteLN(cTab+cTab+'/// <summary>');
      WriteLN(cTab+cTab+'/// Get ' + vB + ' (' + LinkName(aDatei, vIndex) + ').');
      WriteLN(cTab+cTab+'/// </summary>');
      WriteLN(cTab+cTab+'/// <param name="db">Database connection.</param>');
      WriteLN(cTab+cTab+'/// <param name="orderExpression">Lambda order expression.</param>');
      WriteLN(cTab+cTab+'/// <returns>List of ' + vB + '.</returns>');

      WriteCustomAttribs(vFile, aText, aDatei, vIndex, v2Datei, v2Key, aName, vObj2Name);

      WriteLN(cTab+cTab+'public List<'+vObj2Name+'> Get'+vB+'(IDatabase db, Expression<Func<' + vObj2Name + ', LambdaPredicateMethods, bool>> orderExpression = null)');
      WriteLN(cTab+cTab+'{');
    end;


    vB # '';
    vC # '';
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=LinkInfo(aDatei, vIndex, _LinkFldCount)) DO BEGIN
      vTds # LinkFldInfo(aDatei, vIndex, vI, _LinkFldSbrNumber);
      vFld # LinkFldInfo(aDatei, vIndex, vI, _LinkFldNumber);

      vFName # FldName(aDatei, vTds, vFld);
      vK # TextSearch(aText, 1,1, 0, 'F_ALT'+vFName+'|');
      if (vK=0) then begin
WriteERROR('Datei '+aint(aDatei)+': FEHLENDES FELD: '+vFName);
        CYCLE;
      end;
      vA # TextLineRead(aText, vK,0);
      vNewFName # Str_Token(vA,'|',2);

//debug(aint(aDatei)+' '+aint(vIndex)+'  '+aint(vI)+'  nach  '+aint(v2Datei)+' '+aint(v2Key));

      vK # KeyFldInfo(v2Datei, v2Key, vI, _KeyFldSbrNumber);
      vJ # KeyFldInfo(v2Datei, v2Key, vI, _KeyFldNumber);
      v2FName # FldName(v2Datei, vK, vJ);
      vFTyp   # FldInfo(v2Datei, vK, vJ, _FldType);


      vK # TextSearch(aText, 1,1, 0, 'F_ALT'+v2FName+'|');
      if (vK=0) then begin
WriteERROR('Datei '+aint(aDatei)+': FEHLENDES FELD: '+v2FName);
        CYCLE;
      end;
      vA # TextLineRead(aText, vK,0);
      vNew2FName # Str_Token(vA,'|',2);

      if (vB != '') then vB # vB + ' && ';
      vB # vB + 'o.' + vNew2FName + ' == this.' + vNewFName;
    END;

    Write(cTab+cTab+cTab);
    if (v1zu1=false) then
      WriteLN('return db.OrderedFetch<' + vObj2Name + '>(orderExpression, o => ' + vB + ');');
    else
      WriteLN('return db.SingleOrDefault<' + vObj2Name + '>(o => ' + vB + ');');

    WriteLN(cTab+cTab+'}');

  END;  // Verknüpfungen

//  WriteLN(cTab+cTab+'#endregion instance methodes');
//  WriteLN('');


//  WriteLN(cTab+cTab+'public void Randomize()');
//  WriteLN(cTab+cTab+'}');
//  WriteLN(cTab+cTab+'}');
/**
		[DbIgnore]
		public List<Adr_Ansprechpartner> Ansprechpartner{ get { return getAnsprechpartner(null); } }

        public static IEnumerable<Anschrift> GetAnschriften(string aSort)
        {
            return Query_where<Anschrift>("Anschrift.AdressID = " + this.Nummer, aSort);
        }

        public List<Ansprechpartner> GetAnsprechpartner()
        {
            List<Ansprechpartner> ans = new List<Ansprechpartner>();
            return ans;
        }

**/

  WriteLN(cTab+'}');
  WriteLN('}');

  FSIClose(vFile);

  RETURN true;
end;


//========================================================================
//========================================================================
Sub LoadConfig() : int;
local begin
  vTxt            : int;
end;
begin
  vTxt    # TextOpen(10);
  TextRead(vTxt, cConfig_Proc, _textProc);
  RETURN vTxt;
end;


//========================================================================
//========================================================================
//========================================================================
main
local begin
  vTxt        : int;
  vProto      : int;
  vA,vB       : alpha(200);
  vI          : int;
  vDatei      : int;
  vName       : alpha;
  vPrefix     : alpha;
  vNamespace  : alpha;
end;
begin
  Lib_Debug:InitDebug();
/*
FRAMEWORK2CORE();
RETURN;
*/

//vDotNET # false;

  vProto  # TextOpen(10);
  vTxt # LoadConfig();

  // Def-File schreiben...
  FOR vI # 1 loop inc(vI) while (vI<=TextInfo(vTxt,_TextLines)) do begin
    vA # StrAdj( TextLineRead(vTxt, vI, 0) , _StrBegin|_StrEnd);
    if (vA='') then CYCLE;
    if (StrCut(vA,1,2)='//') then CYCLE;
    if (vA='QUIT') then BREAK;
    if (StrCut(vA,1,10)='Namespace:') then begin
      vNamespace # Str_Token(vA,':',2);
      FsiPathCreate(cPath+'\BO');
      FsiPathCreate(cPath+'\BO\'+vNameSpace);
      FsiPathCreate(cPath+'\Core');
      FsiPathCreate(cPath+'\Core\Data');
      FsiPathCreate(cPath+'\Core\Data\'+vNameSpace);
      CYCLE;
    end;

    TokenLine(vA, var vDatei, var vName, var vPrefix);
    if (vPrefix='') then CYCLE;
    if (cTestDatei<>0) and (cTestDatei<>vDatei) then CYCLE;
    if ((vDatei=210) or (vDatei=410) or (vDatei=411) or (vDatei=510) or (vDatei=511)) then CYCLE;
    if (cTest) and ((vDatei<>100) and (vDatei<800)) then CYCLE;

    SaveDEF(vDatei, vName, vPrefix, vProto, vNameSpace)
  END;

  // Fields-File schreiben...
  SaveFIELDS(vProto);


  // QUERY-File schreiben...
  FOR vI # 1 loop inc(vI) while (vI<=TextInfo(vTxt,_TextLines)) do begin
    vA # StrAdj( TextLineRead(vTxt, vI, 0) , _StrBegin|_StrEnd);
    if (vA='') then CYCLE;
    if (StrCut(vA,1,2)='//') then CYCLE;
    if (vA='QUIT') then BREAK;
    if (StrCut(vA,1,10)='Namespace:') then begin
      vNamespace # Str_Token(vA,':',2);
      CYCLE;
    end;

    TokenLine(vA, var vDatei, var vName, var vPrefix);
    if (vPrefix='') then CYCLE;
    if (cTestDatei<>0) and (cTestDatei<>vDatei) then CYCLE;
    if ((vDatei=210) or (vDatei=410) or (vDatei=411) or (vDatei=510) or (vDatei=511)) then CYCLE;
    if (cTest) and ((vDatei<>100) and (vDatei<800)) then CYCLE;

    SaveQUERY(vDatei, vName, vPrefix, vProto, vNameSpace, vTxt);
  END;


/***
    // LOGIC-File schreiben...
    FOR vI # 1 loop inc(vI) while (vI<=TextInfo(vTxt,_TextLines)) do begin
      vA # StrAdj( TextLineRead(vTxt, vI, 0) , _StrBegin|_StrEnd);
      if (vA='') then CYCLE;
      if (StrCut(vA,1,2)='//') then CYCLE;
      if (vA='QUIT') then BREAK;
      if (StrCut(vA,1,10)='Namespace:') then begin
        vNamespace # Str_Token(vA,':',2);
        CYCLE;
      end;

      TokenLine(vA, var vDatei, var vName, var vPrefix);
      if (vPrefix='') then CYCLE;
      if (cTestDatei<>0) and (cTestDatei<>vDatei) then CYCLE;
      if (vByODBC=false) and ((vDatei=210) or (vDatei=410) or (vDatei=411) or (vDatei=510) or (vDatei=511)) then CYCLE;
      if (cTest) and (vDatei<>100) then CYCLE;

      SaveLOGIC(vDatei, vName, vPrefix, vProto, vNameSpace);
    END;
***/

/***
    // SUBVIEWS-File schreiben...
    FOR vI # 1 loop inc(vI) while (vI<=TextInfo(vTxt,_TextLines)) do begin
      vA # StrAdj( TextLineRead(vTxt, vI, 0) , _StrBegin|_StrEnd);
      if (vA='') then CYCLE;
      if (vA='QUIT') then BREAK;
      if (StrCut(vA,1,2)='//') then CYCLE;
      if (StrCut(vA,1,10)='Namespace:') then begin
        vNamespace # Str_Token(vA,':',2);
        CYCLE;
      end;

      // Schluesseldatei bekommt kein SUBVIEW
      if (vNameSpace='Schluesseldatei') then CYCLE;

      TokenLine(vA, var vDatei, var vName, var vPrefix);
      if (vPrefix='') then CYCLE;
      if (cTestDatei<>0) and (cTestDatei<>vDatei) then CYCLE;
      if (vByODBC=false) and ((vDatei=210) or (vDatei=410) or (vDatei=411) or (vDatei=510) or (vDatei=511)) then CYCLE;
      if (cTest) and (vDatei<>100) then CYCLE;

      SaveSUBVIEW(vDatei, vName, vPrefix, vProto, vNameSpace);
    END;
***/

  TextWrite(vProto,'C:\debug\aaa.txt',_textExtern);
  TextClose(vTxt);
  TextClose(vProto);


  WindialogBox(0,'C16 2 C#','Erfolgreich !'+StrChar(13)+cPath,_WinIcoInformation,_windialogok|_WinDialogAlwaysOnTop,1);

  RETURN;

end;

//========================================================================
//========================================================================
//========================================================================