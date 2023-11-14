@A+
//===== Business-Control =================================================
//
//  Prozedur  Test+SQL
//                    OHNE E_R_G
//  Info      Erstellt zu den C16-Dateien passende Klassen für AbcNet anhand
//            dem Config-Prozedurtext
//
//  ginb bis neues PetaPoco kam (14.2.2013)
//
//
//  21.11.2011  AI  Erstellung der Prozedur
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
  cDbg_Filename     : 'e:\debug\debug.txt'
  cConfig_Proc      : 'test+SQL_txt'
  cPath             : 'E:\source\BLOs'
  cTestDatei        : 000

  cSatzEnde         : Strchar(13)+Strchar(10)
  cTab              : StrChar(9)
  cTrans            : '"'

  Str_Token(a,b,c)  : Lib_Strings:Strings_Token(a,b,c)
  AInt(a)           : CnvAI(a,_FmtNumNoGroup)
  TextAddLine(a,b)  : TextLineWrite(a,TextInfo(a,_TextLines)+1,b,_TextLineInsert)
  Write(a)          : begin vOut # Lib_Strings:Strings_Dos2Win(a,n);  FsiWrite(vFile,vOut); end
  WriteLN(a)        : begin vOut # Lib_Strings:Strings_Dos2Win(a+cSatzEnde,n);  FsiWrite(vFile,vOut); end
  WriteERROR(a)     : begin vOut # Lib_Strings:Strings_Dos2Win(a+cSatzEnde,n);  FsiWrite(vFile,vOut); mydebug(a); end
end;

//========================================================================
//========================================================================
//========================================================================

//========================================================================
//  myDebug
//        Schreibt in externe Debugdatei
//========================================================================
sub myDebug(
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

namespace AbcNet.Core.Data
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
  vFile # FSIOpen(cPath+'\Fields.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  /* Dateinamen schreiben */
  WriteLN('// Auto generated by C16');
  WriteLN('using System;');
  WriteLN('');
//  WriteLN('namespace AbcNet.BusinessLogic.'+aNameSpace);
  WriteLN('namespace AbcNet.Core.Data');
  WriteLN('{');
  WriteLN(cTab+'public class Fields');
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
        WriteLN(cTab+cTab+cTab+vFName+'');
      vFName # '';
      if (vTName<>'') then begin
        WriteLN(cTab+cTab+'}'+cTab+'// '+vTName);
        WriteLN('');
      end;
      vTName  # Str_Token(vA,'|',3);  // OBJ-Namen holen
      WriteLN(cTab+cTab+'public enum '+vTName);
      WriteLN(cTab+cTab+'{');
      vFName # '';
    end;
  END;

  WriteLN(cTab+cTab+'}'+cTab+'// '+vTName);
  WriteLN('');

  WriteLN(cTab+'}');
  WriteLN('}');
  WriteLN('');

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
/***
using System;

// Auto generated by C16
using AbcNet.Server.BusinessLogic.ORM;
using AbcNet.Core.Data;
using Fields = AbcNet.Core.Data.Fields;

namespace AbcNet.Server.BO
{
	public partial class Adresse : AbcNet.Core.Data.Adresse, IDbRecord
	{
		public bool Insert()
		{
			// Prüfung vor dem Einfügen in die Datenbank
			DateTime firstDayInSystem = new DateTime(1900, 1, 1, 12, 0, 0);
			this.EK_ZertifikatBis = firstDayInSystem;
			this.VK_EigentumVBDat = firstDayInSystem;
			this.Fibudatum_Kd = firstDayInSystem;
			this.Fibudatum_Lf = firstDayInSystem;
			this.Fin_letzterAufAm = firstDayInSystem;
			this.Fin_letzteReAm = firstDayInSystem;
			this.Fin_Refreshdatum = firstDayInSystem;

			return Database.Insert(this);
		}

		public bool Update()
		{
			return Database.Update(this);
		}
	}
}
***/

  vFile # FSIOpen(cPath+'\'+aNamespace+'\'+aName+'_Logic.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  /* Dateinamen schreiben */
  WriteLN('// Auto generated by C16');
  WriteLN('using AbcNet.Server.BusinessLogic.ORM;');
  WriteLN('using AbcNet.Code.Date;');
  WriteLN('using Fields = AbcNet.Core.Data.Fields;');
  WriteLN('');
//  WriteLN('namespace AbcNet.BusinessLogic.'+aNameSpace);
  WriteLN('namespace AbcNet.Server.BO');
  WriteLN('{');
  WriteLN(cTab+'public partial class '+aName+' : AbcNet.Core.Data.'+aName+', IDbRecord');
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
// Auto generated by C16
using AbcNet.Server.BusinessLogic.ORM;
using AbcNet.Core.Data;
using Fields = AbcNet.Core.Data.Fields;

namespace AbcNet.Server.BO
{
	public partial class Adresse : AbcNet.Core.Data.Adresse, IDbRecord
	{
	}	// Adresse
}
***/
	
  vFile # FSIOpen(cPath+'\'+aNamespace+'\'+aName+'_Subview.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  /* Dateinamen schreiben */
  WriteLN('// Auto generated by C16');
  WriteLN('using System;');
  WriteLN('using AbcNet.Server.BusinessLogic.ORM;');
  WriteLN('using AbcNet.Core.Data;');
  WriteLN('using Fields = AbcNet.Core.Data.Fields;');
  WriteLN('');
//  WriteLN('namespace AbcNet.BusinessLogic.'+aNameSpace);
  WriteLN('namespace AbcNet.Server.BO');//+aNameSpace);
  WriteLN('{');
  WriteLN(cTab+'public partial class '+aName+' : AbcNet.Core.Data.'+aName+', IDbRecord');
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
  WriteLN('// Auto generated by C16');
  WriteLN('using System;');
  WriteLN('namespace AbcNet.Core.Data');
  WriteLN('{');

  WriteLN(cTab+'[DbAutoSync]');
  WriteLN(cTab+'[DbTableName("'+vNewName+'")]');


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
      if (StrFind(StrCnv(vA,_StrUpper),StrCnv(aPrefix,_StrUpper),0)=1) then begin
        end
      else begin
myDebug('bitte prüfen:'+aint(aDatei)+' '+vA);
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
        _TypeAlpha  : begin
          WriteLN(cTab+cTab+'[DbMaxLength('+cnvai(FldInfo(aDatei,vTds,vFld,_FldLen))+')]');
          vTyp # 'string';
          end;
        _TypeDate   : vTyp # 'DateTime';
        _Typeword   : vTyp # 'int';   // war int16
        _typeint    : vTyp # 'int';
        _Typefloat  : vTyp # 'double'; // float??
        _typelogic  : vTyp # 'byte';
        _TypeTime   : vTyp # 'DateTime';
        otherwise vTyp # 'ERROR';
      end;

      vB # C16toCSharp(vA, aPrefix);
TextAddLine(aText, 'F_ALT'+vA+'|'+vB+'|'+vTyp+'|File:'+aint(aDatei));
      vA # 'public '+vTyp+' '+vB;
      vJ # StrLen(vA) div 4;
      //if (StrLen(vA) % 4>0) then inc(vJ);
      FOR vI # 1 loop inc(vI) while (vJ+vI<=12) do begin
        vA # vA + cTab;
      END;

      // not null weil Primary Key?
      if (vTds=1) and
        (StrFind(vKeyA,'|'+aint(vFld)+'|',0)>0) then begin
        WriteLN(cTab+cTab+'[DbNotNull]');
      end;

      WriteLN(cTab+cTab + vA + '{get; set;}');

    END;
  END;

//        public enum DBF
//        {
//            Nummer, Stichwort, Datum, Zeit, DT, Byte, Bool, Bool3, worst
//        }
//        public Adresse()
//        {
//            DateTime firstDayInSystem = new DateTime(1900,1,1,12,0,0);
//            this.EK_ZertifikatBis   = firstDayInSystem;
//        this.VK_EigentumVBDat   = firstDayInSystem;
//		    this.Fibudatum_Kd	    = firstDayInSystem;
//		    this.Fibudatum_Lf		= firstDayInSystem;
//		    this.Fin_letzterAufAm	= firstDayInSystem;
//		    this.Fin_letzteReAm		= firstDayInSystem;
//		    this.Fin_Refreshdatum	= firstDayInSystem;
//        }
/***
  WriteLN('');
  WriteLN('');
  WriteLN(cTab+cTab+ 'public enum DBF');
  WriteLN(cTab+cTab+ '{');
  Write(cTab+cTab+cTab);
  vI # 1;
  vFirst # y;
  REPEAT
    vI # TextSearch(aText, vI,1, 0, '|File:'+aint(aDatei));
    if (vI=0) then BREAK;

    vA # TextLineRead(aText, vI,0);
    vA # Str_Token(vA,'|',2);
    if (vFirst) then begin
      vFirst # n;
      Write(vA);
      end
    else begin
      Write(', '+vA);
    end;
    inc(vI);
  UNTIL (vI=0);
  WriteLN('');
  WriteLN(cTab+cTab+ '}');
***/
  // 3 Tabs = 12 Zeichen
  // 123 = 0 = 3T
  // 1 = 0 = 3T
  // 1234 = 1 = 2T
  // 12345 = 1 = 2T
  // 12345678 = 2 = 1T
  // 123456789 = 2 =1T

  WriteLN(cTab+'}'+cTab+'// '+vNewName);
  WriteLN('}');
  WriteLN('');

  FSIClose(vFile);

  RETURN true;
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
  vString     : alpha(200);
  vIsSTring   : logic;
  vObj2Name   : alpha;
end;
begin
	
  vFile # FSIOpen(cPath+'\'+aNameSpace+'\'+aName+'_Generated.cs', _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then begin
    RETURN false;
  end;

  vTName # C16toCSharp(Filename(aDatei), aPrefix);

  /* Dateinamen schreiben */
  WriteLN('// Auto generated by C16');
  WriteLN('using System;');
  WriteLN('using AbcNet.Server.BusinessLogic.ORM;');
  WriteLN('using AbcNet.Core.Data;');
  WriteLN('using System.Collections.Generic;');
  WriteLN('using System.Linq;');
  WriteLN('using Fields = AbcNet.Core.Data.Fields;');
  WriteLN('');
//  WriteLN('namespace AbcNet.BusinessLogic.'+aNameSpace);
  WriteLN('namespace AbcNet.Server.BO');//+aNameSpace);
  WriteLN('{');
  WriteLN(cTab+'public partial class '+aName+' : AbcNet.Core.Data.'+aName+', IDbRecord');
  WriteLN(cTab+'{');
  WriteLN('');

  WriteLN(cTab+cTab+'#region static methodes');
  WriteLN('');
//        public static Adresse Get(int aNummer)
//        {
//            return Database.List_where<Adresse>("Nummer = " + aNummer, "").FirstOrDefault();
//        }
//
//        public static List<Adresse> GetAll(string aWhere = "", string aSort = "", string aSubTables = "")
//		    {
//            return Database.List_where<Adresse>(aWhere, aSort, aSubTables);
//        }
//
//		    public static List<Adresse> GetRandom(int aAnz = 10)
//    		{
//    			return RandomUtil.Random<Adresse>(aAnz);
//    		}
//
//
//        public static TEST GetByStichwort(string aStichwort)
//        {
//            aStichwort = aStichwort.Replace("'", "''");
//            Database.SafeSQL(ref aStichwort);
//            return Database.List_where<TEST>("Stichwort = '" + aStichwort + "'", "").FirstOrDefault();
//        }
//  WriteLN(cTab+cTab+'public static '+aName+' Get(int aNummer)');
//  WriteLN(cTab+cTab+'{');
//  WriteLN(cTab+cTab+cTab+'return Database.List_where<Adresse>("Nummer = " + aNummer + " AND Horst = " + aBub, "").FirstOrDefault();');
//  WriteLN(cTab+cTab+'}');

  // PRIMARY KEY ***************************************************
  vB # '';
  vC # '';
  vString # '';
  vJ # KeyInfo(aDatei, 1, _KeyFldCount);
  FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
    vFld # KeyFldInfo(aDatei,1,vI,_KeyFldNumber);
    vTds # KeyFldInfo(aDatei,1, vI, _KeyFldSbrNumber);

    vFName # FldName(aDatei, vTds, vFld);

    vK # TextSearch(aText, 1,1, 0, 'F_ALT'+vFName);
    if (vK=0) then begin
WriteERROR('Datei '+aint(aDatei)+': FEHLENDES FELD: '+vFName);
      CYCLE;
    end;
    vA # TextLineRead(aText, vK,0);
    vNewFName # Str_Token(vA,'|',2);
    vTyp # Str_Token(vA,'|',3);

    vIsString # n;
    if (FldInfo(aDatei,vTds,vFld,_FldType)=_Typealpha) then begin
      vString # vString + 'Database.SafeSQL(ref a'+vNewFName+');';
      vIsString # y;
    end;

    if (vB<>'') then vB # vB + ', ';
    vB # vB + vTyp+' '+'a'+vNewFName;

    if (vC<>'') then vC # vC + ' + " AND " + ';


    vA # aName + '.' + vNewFName;

    if (vIsString) then
      vC # vC + 'Fields.'+vA+' + " = ''" + a'+vNewFName+' + "''"'
    else
      vC # vC + 'Fields.'+vA+' + " = " + a'+vNewFName;

    // "datei"."feld" = "+xxx
  END;


  WriteLN(cTab+cTab+'public static '+aName+' Get('+vB+')');
  WriteLN(cTab+cTab+'{');
  if (vString='') then begin
    WriteLN(cTab+cTab+cTab+'return Database.List_where<'+aName+'>('+vC+',"").FirstOrDefault();');
    end
  else begin
    WriteLN(cTab+cTab+cTab+vString);
    WriteLN(cTab+cTab+cTab+'return Database.List_where<'+aName+'>('+vC+',"").FirstOrDefault();');
  end;
  WriteLN(cTab+cTab+'}');
  WriteLN('');
  WriteLN('');

  WriteLN(cTab+cTab+'public static List<'+aName+'> GetAll(string aWhere = "", string aSort = "", string aSubTables = "")');
  WriteLN(cTab+cTab+'{');
  WriteLN(cTab+cTab+cTab+'return Database.List_where<'+aName+'>(aWhere, aSort, aSubTables);');
  WriteLN(cTab+cTab+'}');
  WriteLN('');
  WriteLN('');

  WriteLN(cTab+cTab+'#endregion static methodes');
  WriteLN('');


  WriteLN('');
  WriteLN(cTab+cTab+'#region instance methodes');
  WriteLN('');

  // Verknüpfungen loopen ------------------------------------------------------------------

  FOR vIndex # 1 loop inc(vIndex) WHILE (LinkInfo(aDatei, vIndex, _LinkExists)>0) do begin

    if (StrLen(LinkName(aDatei,vIndex))<=3) then begin
myDebug('Verknüpfung '+aint(aDatei)+' '+aint(vIndex)+' uebersprungen!');
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
myDebug('Verknüpfung '+aint(aDatei)+' '+aint(vIndex)+' hat komischen Namen:'+LinkName(aDatei, vIndex));
      vB # vNew2TName;
      end
    else begin
      vB # C16toCSharp(vB, '');
      vB # Lib_strings:Strings_ReplaceAll(vB, '_', '');
      vB # Lib_strings:Strings_ReplaceAll(vB, '~', 'Ablage');
    end;

    if (v1zu1) then begin
      WriteLN(cTab+cTab+'// '+vB);

/*        // Position
		private Auf_Position positionObj;
		[DbIgnore]
		public Auf_Position PositionObj
		{
			get {
				if (positionObj == null)
					positionObj = GetPosition();
				return positionObj;
			}
		}
*/
      // erstes Zeichen GROSS wandeln
      vB # StrCnv(StrCut(vB,1,1),_strUpper)+StrCut(vB,2,1000);

      // erstes Zeichen KLEIN schreiben
      vB2 # StrCnv(StrCut(vB,1,1),_strlower)+StrCut(vB,2,1000);

      // für Lazy-Loading...
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
//      WriteLN(cTab+cTab+'private '+vObj2Name+' Get'+vB+'()');
      WriteLN(cTab+cTab+'public '+vObj2Name+' Get'+vB+'()');
      WriteLN(cTab+cTab+'{');
      end
    else begin
      vI # TextSearch(aConfigTxt, 1,1,0, 'MULTILINK '+aint(aDatei)+' '+cnvai(vIndex,0,0,2)+':');
      if (vI=0) then begin
myDebug('fehlt: MULTILINK '+aint(aDatei)+' '+cnvai(vIndex,0,0,2)+':'+vB);
          CYCLE;
        end
      else begin
        vB # TextLineRead(aConfigTxt, vI, 0);
        vB # Str_token(vB,':',2);
        if (StrLen(vB)<3) then begin
myDebug('Verknüpfung '+vB+' übersprungen bei '+aint(aDatei));
          CYCLE;
        end;
      end;
//myDebug('MULTILINK '+aint(aDatei)+' '+cnvai(vIndex,0,0,2)+':'+vB);

      WriteLN(cTab+cTab+'// '+LinkName(aDatei, vIndex));

      WriteLN(cTab+cTab+'public List<'+vObj2Name+'> Get'+vB+'(Enum[] aSortFields = null)');
      WriteLN(cTab+cTab+'{');
      WriteLn(cTab+cTab+cTab+'string vSort = "";');
			WriteLn(cTab+cTab+cTab+'if (aSortFields!=null) string.Join(", ", aSortFields.Select(x => x.ToString()).ToArray());');
    end;


    vB # '';
    FOR vI # 1 loop inc(vI) while (vI<=LinkInfo(aDatei, vIndex, _LinkFldCount)) do begin
      vTds # LinkFldInfo(aDatei, vIndex, vI, _LinkFldSbrNumber);
      vFld # LinkFldInfo(aDatei, vIndex, vI, _LinkFldNumber);

      vFName # FldName(aDatei, vTds, vFld);
      vK # TextSearch(aText, 1,1, 0, 'F_ALT'+vFName);
      if (vK=0) then begin
WriteERROR('Datei '+aint(aDatei)+': FEHLENDES FELD: '+vFName);
        CYCLE;
      end;
      vA # TextLineRead(aText, vK,0);
      vNewFName # Str_Token(vA,'|',2);

//mydebug(aint(aDatei)+' '+aint(vIndex)+'  '+aint(vI)+'  nach  '+aint(v2Datei)+' '+aint(v2Key));

      vK # KeyFldInfo(v2Datei, v2Key, vI, _KeyFldSbrNumber);
      vJ # KeyFldInfo(v2Datei, v2Key, vI, _KeyFldNumber);
      v2FName # FldName(v2Datei, vK, vJ);
      vFTyp   # FldInfo(v2Datei, vK, vJ, _FldType);


      vK # TextSearch(aText, 1,1, 0, 'F_ALT'+v2FName);
      if (vK=0) then begin
WriteERROR('Datei '+aint(aDatei)+': FEHLENDES FELD: '+v2FName);
        CYCLE;
      end;
      vA # TextLineRead(aText, vK,0);
      vNew2FName # Str_Token(vA,'|',2);

      if (vB<>'') then vB # vB + '+ " AND " + ';


      vA # vObj2Name + '.' + vNew2FName;

      if (vFTyp=_TypeAlpha) then
        vB # vB + 'Fields.'+vA+ ' + " = ''" + this.'+vNewFName+' + "''"'
      else
        vB # vB + 'Fields.'+vA+ ' + " = " + this.'+vNewFName;
    END;

    if (v1zu1=false) then begin
// 17.33      vB # 'return Database.List_where<'+vNew2TName+'>('+ vB;
      vB # 'return Database.List_where<'+vObj2Name+'>('+ vB;
      WriteLN(cTab+cTab+cTab+vB+', vSort);');
      end
    else begin
// 17.33      vB # 'return Database.List_where<'+vNew2TName+'>('+ vB;
      vB # 'return Database.List_where<'+vObj2Name+'>('+ vB;
      WriteLN(cTab+cTab+cTab+vB+', "").FirstOrDefault();');
    end;
    WriteLN(cTab+cTab+'}');
    WriteLN('');
    WriteLN('');

  END;  // Verknüpfungen

  WriteLN('');
  WriteLN(cTab+cTab+'#endregion instance methodes');
  WriteLN('');


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

  WriteLN(cTab+'}'+cTab+'// '+vTName);
  WriteLN('}');
  WriteLN('');

  FSIClose(vFile);

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
main
local begin
  vTxt        : int;
  vProto      : int;
  vA,vB       : alpha;
  vI          : int;
  vDatei      : int;
  vName       : alpha;
  vPrefix     : alpha;
  vNamespace  : alpha;
end;
begin
  Lib_Debug:InitDebug();

//vDotNET # false;

  vTxt    # TextOpen(10);
  vProto  # TextOpen(10);

  TextRead(vTxt, cConfig_Proc, _textProc);

  // Def-File schreiben...
  FOR vI # 1 loop inc(vI) while (vI<=TextInfo(vTxt,_TextLines)) do begin
    vA # StrAdj( TextLineRead(vTxt, vI, 0) , _StrBegin|_StrEnd);
    if (vA='') then CYCLE;
    if (StrCut(vA,1,2)='//') then CYCLE;
    if (vA='QUIT') then BREAK;
    if (StrCut(vA,1,10)='Namespace:') then begin
      vNamespace # Str_Token(vA,':',2);
      FsiPathCreate(cPath+'\'+vNameSpace);
      FsiPathCreate(cPath+'\Core');
      FsiPathCreate(cPath+'\Core\Data');
      FsiPathCreate(cPath+'\Core\Data\'+vNameSpace);
      CYCLE;
    end;

    TokenLine(vA, var vDatei, var vName, var vPrefix);
    if (vPrefix='') then CYCLE;
    if (cTestDatei<>0) and (cTestDatei<>vDatei) then CYCLE;
    if ((vDatei=210) or (vDatei=410) or (vDatei=411) or (vDatei=510) or (vDatei=511)) then CYCLE;

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

      SaveSUBVIEW(vDatei, vName, vPrefix, vProto, vNameSpace);
    END;
***/

//TextWrite(vProto,'E:\aaa.txt',_textExtern);
  TextClose(vTxt);
  TextClose(vProto);


  WindialogBox(0,'C16 2 C#','Erfolgreich !',_WinIcoInformation,_windialogok|_WinDialogAlwaysOnTop,1);

  RETURN;

end;

//========================================================================
//========================================================================
//========================================================================