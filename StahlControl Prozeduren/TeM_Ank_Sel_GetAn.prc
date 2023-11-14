@A+
//==== Business-Control ==================================================
//
//  Prozedur    TeM_Ank_Select_GetAn
//                OHNE E_R_G
//  Info
//    Öffent die Ankerauswahl und wertet den Ausgewerteten Anker aus
//
//
//  28.06.2003  ST  Erstellung der Prozedur
//  27.08.2009  MS  Um neue Datein erweitert, alte geprüft
//
//  Subprozeduren
//    SUB EvtClicked(aEvt : event) : logic
//========================================================================

@I:Def_Global


LOCAL begin
  vKey    : int;
end;

//========================================================================
// EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt          : event;  // Ereignis
) : logic
begin

  case aEvt:obj->wpname of

    'bt.User'         : vKey # 800;
    'bt.Adresse'      : vKey # 100;
    'bt.Auftrag'      : vKey # 401;
    'bt.Bestellung'   : vKey # 501;
    'bt.Partner'      : vKey # 102;
    'bt.Projekt'      : vKey # 120;
    'bt.Projektpos'   : vKey # 122;
    'bt.Material'     : vKey # 200;
    'bt.BAG_Pos'      : vKey # 702;

  end;

  gSelected # vKey;
  if (vKey<>0) then $TeM.Anker.Auswahl->Winclose();

  RETURN(true);
end;



//========================================================================