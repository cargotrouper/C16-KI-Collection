@A+
//===== Business-Control =================================================
//
//  Prozedur    Def_SOA
//                    OHNE E_R_G
//  Info        globale Variabeln/Makrodefinition für die SOA Implementierung
//
//
//  07.09.2010  ST  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================

define begin
  errMsg(a)    : StrCut(Lib_Messages:Fehlertext(a),3,999)
  errMsgPara(a,b)    : Lib_Soa:ParseErrMsg(Lib_Messages:Fehlertext(a),b)

/*
  SOA_TRANSON  : DtaBegin();
  SOA_TRANSOFF : DtaCommit();
  SOA_TRANSBRK : DtaRollback(false);
*/
  SOA_TRANSON  : Lib_Rec:RekTransOn();
  SOA_TRANSOFF : Lib_Rec:RekTransOff();
  SOA_TRANSBRK : Lib_Rec:RekTransBrk();

end;

// Fehlercodes *************************************
define begin
  errPrevent              : -1

  // Spezielle Fehlercodes ***************************************************
  // ExecMemory: Fehlercode der `exec`-Subprozedur, die die Ausführung der
  //   `execMemory`-Subprozedur ankündigt. Diese schreibt die Serviceantwort
  //   direkt in ein Memory-Objekt, und umgeht somit die XML-Struktur.
  errSVL_ExecMemory      : -4203520

  // Servicelayer ******************* Text aus Lib_Messages ******
  errSVL_Allgemein       : 960101 //: vA # 'E:Allgemeiner Service Fehler';
  errSVL_Prot            : 960102 //: vA # 'E:Protokollierungsfehler';
  errSVL_Prot_Insert     : 960103 //: vA # 'E:Das Protokoll konnte nicht erweitert werden';
  errSVL_Prot_ReadLock   : 960104 //: vA # 'E:Der passende Protokolleintrag konnte nicht gefunden werden';
  errSVL_Prot_Update     : 960105 //: vA # 'E:Der passende Protokolleintrag konnte nicht aktualisiert werden';
  errSVL_Prot_LogFileDir : 960106 //: vA # 'E:Protokollierungsfehler: Logdatei konnte nicht angelegt werden.';
  errSVL_Prot_LogFile    : 960107 //: vA # 'E:Protokollierungsfehler: LogVerzeichnis konnte nicht angelegt werden.';

  // Servicemanagement  ***********************************************
  errSVM_noService       : 960203 //: vA # 'E:Kein Service angegeben';
  errSVM_noUser          : 960204 //: vA # 'E:Kein Servicebenutzer angegeben';
  errSVM_ServiceUnknown  : 960205 //: vA # 'E:Der angeforderte Service wurde nicht gefunden';
  errSVM_ServiceLocked   : 960206 //: vA # 'E:Der angeforderte Service wird zur Zeit nicht angeboten';
  errSVM_ServiceProc     : 960207 //: vA # 'E:Der angeforderte Service steht zur Zeit nicht zur Verfügung';
  errSVM_notAllowed      : 960208 //: vA # 'E:Autorisierung für den angeforderten Service fehlgeschlagen';
  errSVM_noKeySC         : 960209 //: vA # 'E:Autorisierung für den angeforderten Service fehlgeschlagen. Bitte Serviceanbieter kontaktieren.';
  errSVM_AuthFailed      : 960210 //: vA # 'E:Autorisierung für den angeforderten Service fehlgeschlagen. Bitte Zugangsdaten prüfen.';

  // Serviceausführung ************************************************
  errSVC_argGeneral      : 960301 //: vA # 'E:Argumentfehler';
  errSVC_argNotFound     : 960302 //: vA # 'E:Argument nicht gefunden';
  errSVC_argNoValue      : 960303 //: vA # 'E:Argument hat keinen Wert';
  errSVC_argValueToLow   : 960304 //: vA # 'E:Argumentwert zu klein';
  errSVC_argValueToHigh  : 960305 //: vA # 'E:Argumentwert zu groß';
  errSVC_argWrongType    : 960306 //: vA # 'E:Argumentwert entspricht nicht dem gewünschten Typ';
  errSVC_argChoice       : 960307 //: vA # 'E:Argumentwert entspricht nicht der möglichen Werte';
end;