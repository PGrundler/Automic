/* (c) GP

Rückfragen an: peter.grundler@automic.com

2014.05.07: Erweiterung auf PUT_VAR mit Script-Variablen
			Änderung der Suche nach MODIFY_TASK: RESULT-Karte
			lower (OT_Content)
			Suche nach CINT und CSTR
			Suche nach Objekt TZ.MST
			Parameter Server_Options in UC_SYSTEM_SETTINGS
			Suche nach GET_VAR

2014.05.08: zusätzliche Info bei den jeweiligen Statements, warum es notwendig ist
			für v10: Ausgabe der FT-Parameter in der Hostchar

2014.05.21: Liste der Benutzer und Gruppen
			Verwendung von VERSION_MANAGEMENT ausgeben
			Erweiterung in der GET_VAR Suche: nur mehr inkompatible Zeilen ausgeben

2014.05.23: Erweiterung PUT_VAR: nur mehr inkompatible Zeilen ausgeben
			diverse Anpassungen, um das Ergebnis zu präzisieren
			
2014.07.02:	Jobplan - Resultkarte: Prüfung auf "ELSE Ablaufplan abbrechen"

2014.07.22: Anpassung mancher Kommandos an v8

2014.07.31: Liste von Zugriffen über API

2014.08.01: Anpassung von Statements an Oracle

2014.08.07: GET_VAR: Bessere Abfrage bei MSSQL (POM)

2014.08.12: GET_VAR/PUT_VAR: Anpassung der Spalten an das Eingabeformat des Upgradeprogramms
			Hinweise zur Verwendung des Tools

2014.08.19: Erweiterung JOBP: suche nach konfigurierter Result-Karte

2014.09.16: Prüfung auf Script-Variablen, deren Namen mit "&$" beginnt

2014.09.17: Prüfung auf Script-Variablen, deren Namen länger als 32 Zeichen ist

2014.09.23: Prüfung auf CONV_DATE ("Rück"Änderung in v10 SP3)
            Prüfung auf Objektvariablen mit Hochkomma (v9 SP5)
			
2014.10.08: Prüfung auf nicht mehr gültige Status-Namen "INAKTIV -> INACTIV"

2014.10.15: Prüfung der SAP spool expiration
			viele Kunden verwenden irrtümlich eine 2stellige Zahl, die mit dem SAPJCO v3 zu einem Fehler führt
			
2014.10.21: Erweiterung für Oracle: in SQLplus die Ersetzung von Variablen ausschalten

2014.11.04: Erweiterung Anzahl der Datensätze OH, RH und RT

2014.11.14: Prüfung der PostCondition auf inkorrekte Konfiguration

2014.12.02: Fehler in Abfrage GET_PROCESS_LINE behoben

2014.12.09: Korrektur bei Abfrage "nicht mehr gültige STATUS-Namen suchen"

2015.02.10: R3_SET_PRINT_DEFAULTS

2015.02.11: Suche in VARA nach &&
			Erweiterung Skriptvariablen länger 31 Zeichen auf Kommandos und nun inkl. Mandant 0
			Anpassung Suche nach SAP spool expiration
			
2015.02.13: Liste aller UC_OBJECT_* Objekte; ggf. die TEMPLATEs nach dem Upgrade anpassen - neue Objekttypen hinzufügen

2015.02.28: Prüfung auf nicht länger unterstützte Script-Sprachmittel laut Doku erweitert

2015.05.19: SEND_MAIL - Adresszeile (to, from) darf nicht mit ";" beginnen -- vermutlich ein Bug im Server

2015.05.26: Anpassung an ANSI SQL-92 Standards
			Optimierung der LIKE Suche: keine Wildcard am Beginn des Suchstrings
			mehrere SELECTS mit UNION verknüpft -> ein SELECT mit mehreren LIKE
			
2015.06.22: READ mit Kleinbuchstaben

2015.07.04: diverse Anpassungen bezüglich CSV-Ausgabe

2015.07.08: User ohne Gruppenzuordnung und mit Zuordnung
			Erweiterung der Übersicht OH/AH/RT aufgeteilt auf Clients
			Anpassung OH_Idnr
			diverse Anpassungen und Optimierungen
			
2015.08.24: as of v10SP5 GET_VAR does no longer resolve script variables recursively
			search for RESOLVE_GET_VAR in UC_SYSTEM_SETTINGS

2016.02.03: Update on reports regarding User/UserGroup and assignments, ACL, Privileges

2016.02.23: change SQL query for RESULT_CANCEL

2016.03.09: check of Archive/Reorg flagged entries

2016.03.16: Change in FT_PREP_REP:  ...(OT_Content) like ':%prep_process_rep&' ->  ...(OT_Content) like ':%prep_process_rep%'

2016.08.16: INC00118758 - R3_IMPORT_JOBS aborts with an error; SAP Agent has to be exactly on the same version as AE
			change: SQL query for STOP MSG
			change: last user session
			new: Objects grouped by OH_DeleteFlag
			various optimizations

2016.12.21: add search for UC_OBJECT_* Variables

2019.04.03: search for CallAPI execution in Object process tab
*/

/* The scripts below till the ////////// line can be sent to the customer and will return results in a .csv readable format. 
   It can also be used within an Automic SQL Job */

print 'OBJECT_VARA_X_WF;>> E: Object variable names matching "&X", "&XC", "&XC_", "%&XC%" in workflow tasks are no longer allowed. <<' ;
print 'OBJECT_VARA_X_WF;Client;ObjectName;ObjectVariable' ; 
select 'OBJECT_VARA_X_WF;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OV_VName
 from OH inner join 
	OV on (OH_Idnr = OV_OH_Idnr)
  where OH_DeleteFlag = 0
  and (OV_VName = '&X' or OV_VName = '&XC' or OV_VName = '&XC_' or OV_VName like '%&XC%')
  and OH_Name in (select JPP_Object from JPP);

print 'OBJECT_VARA_X_RSET;>> E: Use of PSET and RSET with script variables matching "&X", "&XC", "&XC_", "%&XC%" is not allowed. <<' ;  
print 'OBJECT_VARA_X_RSET;Client;ObjectName;Type;Lnr;Content' ;    
select 'OBJECT_VARA_X_RSET;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where OH_Name not like '<%>'
 and OH_DeleteFlag = 0
 and (lower(OT_Content) like ':%rset%&x[ =]%'
  or lower(OT_Content) like ':%rset%&x'
  or lower(OT_Content) like ':%rset%&xc[ =]%'
  or lower(OT_Content) like ':%rset%&xc'
  or lower(OT_Content) like ':%rset%&xc+_' escape '+'
  or lower(OT_Content) like ':%rset%&xc+_[ =]%' escape '+'
  or lower(OT_Content) like ':%pset%&x[ =]%'
  or lower(OT_Content) like ':%pset%&x'
  or lower(OT_Content) like ':%pset%&xc[ =]%'
  or lower(OT_Content) like ':%pset%&xc'
  or lower(OT_Content) like ':%pset%&xc+_' escape '+'
  or lower(OT_Content) like ':%pset%&xc+_[ =]%' escape '+')
 order by OH_Client,OH_Name;

print 'SYSTEM_VARA;>> W: Starting with V9 predefined script variables use the prefix &$ which may collide with already defined variables <<';
print 'SYSTEM_VARA;Client;Name;Lnr;Content' ;
select 'SYSTEM_VARA;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where OT_Content like ':%&$%'
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

print 'AUTO_GROUPS;>> I: LIST OF AUTOMATIC GROUPS (to be compared with the next output) <<' ;
print 'AUTO_GROUPS;Client;Name' ;
select 'AUTO_GROUPS;'+cast(OH_Client as varchar(20))+';'+OH_Name
 from OH inner join
      OGA on (OH_Idnr = OGA_OH_Idnr)
 where OH_OType = 'JOBG'
 and OGA_StartMode = 1 
 and OGA_Perm = 1
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name;

print 'PUT_ATT_STARTTYPE;>> E: PUT_ATT START_TYPE for automatic groups must be changed to PUT_ATT QUEUE <<' ;
print 'PUT_ATT_STARTTYPE;Client;Idnr;Name;Type;Lnr;Content' ;    
select 'PUT_ATT_STARTTYPE;'+cast(OH_Client as varchar(20))+';'+cast(OH_Idnr as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content from OT,OH
 where OT_OH_Idnr=OH_Idnr and lower(OT_Content) like ':%put_att% start_type%=%'
union
select 'PUT_ATT_STARTTYPE;'+cast(OH_Client as varchar(20))+';'+cast(OH_Idnr as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content from OT,OH
 where OT_OH_Idnr=OH_Idnr and lower(OT_Content) like ':%put_att% group=%'
union
select 'PUT_ATT_STARTTYPE;'+cast(OH_Client as varchar(20))+';'+cast(OH_Idnr as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content from OT,OH
 where OT_OH_Idnr=OH_Idnr and lower(OT_Content) like ':%put_att% group %=%'
union
select 'PUT_ATT_STARTTYPE;'+cast(OH_Client as varchar(20))+';'+cast(OH_Idnr as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content from OT,OH
 where OT_OH_Idnr=OH_Idnr and lower(OT_Content) like ':%put_att% s=%'
union
select 'PUT_ATT_STARTTYPE;'+cast(OH_Client as varchar(20))+';'+cast(OH_Idnr as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content from OT,OH
 where OT_OH_Idnr=OH_Idnr and lower(OT_Content) like ':%put_att% s %=%';

print 'STOP_NR;>> E: STOP (NO)MSG only accepts message numbers from 50 to 59. <<' ; 
print 'STOP_NR;Client;Name;Type;Lnr;Content' ;  
select 'STOP_NR;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
	  OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%stop%msg%,%'
 and OT_Content not like ':%5[0-9][^0-9]%'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name,OT_Lnr;

print 'RESULT_MODIFY_TASK;>> E: MODIFY_TASK can not be used for result tab <<' ; 
print 'RESULT_MODIFY_TASK;Client;Name;Type;Lnr;Content' ;  
select 'RESULT_MODIFY_TASK;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%modify_task%,%result%,%'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name,OT_Lnr;

print 'TOGGLE_SYSTEM_STATUS;>> W: Use of TOGGLE_SYSTEM_STATUS by CallAPI requires active queue. <<' ; 
print 'TOGGLE_SYSTEM_STATUS;Client;Name;Type;Lnr;Content' ;  
select 'TOGGLE_SYSTEM_STATUS;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%toggle_system_status%'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name,OT_Lnr;

print 'GET_STATISTIC_DETAIL;>> I: GET_STATISTIC_DETAIL returns empty string instead of runtime error in case of missing statistical record. <<' ; 
print 'GET_STATISTIC_DETAIL;Client;Name;Type;Lnr;Content' ;  
select 'GET_STATISTIC_DETAIL;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%get_statistic_detail%'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name,OT_Lnr;
 
print 'TOP_NR;Client;Name;Type;Lnr;Content' ;  
select 'TOP_NR;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%sys_act_top%'
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr; 

print 'GET_VAR;>> E: GET_VAR - Key must be quoted if character string. <<' ;
print 'GET_VAR;Client;Name;OType;Type;Lnr;Content' ;  
select 'GET_VAR;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OH_OType+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH left outer join
      OEA on (OH_Idnr = OEA_OH_Idnr) inner join
	  OT on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%=%get_var%(%,%)'
 and  (lower(OT_Content) not like ':%=%get_var%(%,%&%)')  /* uncomment this line to exclude script vars */
 and  (lower(OT_Content) not like ':%,%''%'
 and   lower(OT_Content) not like ':%,%"%')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Type,OT_Lnr;
 
/* obsolet, weil durch 2. Statement abgedeckt -> Matthias fragen
print 'PUT_VAR_COMMA;>> E: PUT_VAR-value allows no comma(s) -> value may need to be quoted. <<' ;
print 'PUT_VAR_COMMA;Client;Name;OType;EventType;Type;Lnr;Content' ;  
select 'PUT_VAR_COMMA;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OH_OType+';'+ISNULL(oea_eventtype,'-')+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content from oh
 left outer join oea on oh.oh_idnr = oea.oea_oh_idnr inner join ot on ot_oh_idnr = oh_idnr
 where OT_OH_Idnr = OH_Idnr
 and lower(OT_Content) like ':%put_var%'
 and (lower(OT_Content) not like '%,%,%'''
 and  lower(OT_Content) not like '%,%,%"')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;
*/

print 'PUT_VAR_2;>> E: PUT_VAR value not passed as quoted string or script variable. <<' ; 
print 'PUT_VAR_2;Client;Name;OType;Type;Lnr;Content' ;  
select 'PUT_VAR_2;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OH_OType+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH left outer join
 	  OEA on (OH_Idnr = OEA_OH_Idnr) inner join
	  OT on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%put_var%'
 and   lower(OT_Content) not like ':%,%,%'''
 and   lower(OT_Content) not like ':%,%,%"'
 and   lower(OT_Content) not like ':%,%,%&%'
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

print 'PUT_VAR_3;>> E: PUT_VAR require multiple script variables to be quoted in order to pass them as 1 concatenated value. <<' ; 
print 'PUT_VAR_3;Client;Name;OType;Type;Lnr;Content' ;  
select 'PUT_VAR_3;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OH_OType+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH left outer join
      OEA on (OH_Idnr = OEA_OH_Idnr) inner join
	  OT on (OT_OH_Idnr = OH_Idnr)
 where (lower(OT_Content) like ':%put_var%,%,%&%&%')
 and   (lower(OT_Content) not like ':%"')
 and   (lower(OT_Content) not like ':%''')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

print 'SEND_MAIL_ATT;>> E: SEND_MAIL attachments are sent by the AE server only. <<' ;
print 'SEND_MAIL_ATT;Client;Name;OType;Lnr;Content' ;     
select 'SEND_MAIL_ATT;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%=%send_mail%(%,%,%,%,%/%)'
 or    lower(OT_Content) like ':%=%send_mail%(%,%,%,%,%\%)'
 or    lower(OT_Content) like ':%=%send_mail%(%,%,%,%,%.%)'
 or    lower(OT_Content) like ':%=%send_mail%(%,%,%,%,%&%)'
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

print 'SEND_MAIL_SEMI;>> E: SEND_MAIL address must not start with semicolon - probably a bug in v10. <<' ;
print 'SEND_MAIL_SEMI;Client;Name;OType;Lnr;Content' ;  
select 'SEND_MAIL_SEMI;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OH_Idnr = OT_OH_Idnr)
 where lower (OT_Content) like ':%set%;%@%'
 and OH_Idnr >= 100000
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name 

print 'GET_PROCESS_LINE_VAR;>> E: Use of GET_PROCESS_LINE for PREP_PROCESS_VAR without passing a specific column returns key and 5 values separated by 3 paragraph signs. <<' ; 
print 'GET_PROCESS_LINE_VAR;Client;Name;OType;Lnr;Content' ;  
select 'GET_PROCESS_LINE_VAR;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%get_process_line%(%)'
 and lower(OT_Content) not like ':%get_process_line%(%,%)'
 and OT_OH_Idnr in (select OT_OH_Idnr from OT where lower(OT_Content) like ':%prep_process_var%')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

print 'FT_PREP_REP;>> W: PREP_PROCESS_REPORT in FTs might not work anymore as FT reports have changed. <<' ;   
print 'FT_PREP_REP;Client;Name;Type;Lnr;Content' ;  
select 'FT_PREP_REP;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%prep_process_rep&'
 and OH_OType = 'JOBF'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name,OT_Lnr;
 
/* 1 Statement adapted, 12.02.2015, POM */
print 'TZ_MST;>> E: TZ.MST is now part of initial data (has to be deleted or renamend in C0) <<' ;
print 'TZ_MST;Client;Idnr;Name;UserCreated' ;
select 'TZ_MST;'+cast(OH_Client as varchar(20))+';'+cast(OH_Idnr as varchar(20))+';'+OH_Name+';'+cast(OH_CrUserIdnr as varchar(20)) from OH
 where OH_Client = 0
 and lower(OH_Name) = 'tz.mst'
 and OH_DeleteFlag = 0
 order by OH_Client;

/* Verwendung von Objekt TZ.MST */
print 'TZ.MST_USAGE>> I: Use of new standard timezone TZ.MST in all clients. <<' ;
print 'TZ.MST_USAGE;Client;Idnr;Name' ;
select 'TZ_MST_USAGE;'+cast(OH_Client as varchar(20))+';'+cast(OH_Idnr as varchar(20))+';'+OH_Name from OH
 where (lower(OH_TZ)    = 'tz.mst'
 or     lower(OH_MrtTZ) = 'tz.mst')
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name;

print 'SRV_NAMES;>> E: All UC4/AE server processes must use the same AE/UC4 system name. <<' ;
print 'SRV_NAMES;Name' ;
select 'SRV_NAMES;'+OH_Name from OH
 where OH_Client = '0000'
 and OH_OType = 'SERV'
 and OH_DeleteFlag = 0 
 order by OH_Name;

print 'RESULT_CANCEL;>> W: RESULT tab in workflows - Used to cancel workflow (behaves different in V9/10). <<' ; 
print 'RESULT_CANCEL;Client;JPName;Lnr;Object;OType;OKStatus;Execute;Repeat;Delay;Else' ;     
select 'RESULT_CANCEL;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(JPP_Lnr as varchar(20))+';'+JPP_Object+';'+JPP_OType+';'
        +JPP_RWhen+';'+isnull(JPP_RExecute,'')+';'+cast(JPP_RRepMTimes as varchar(20))+';'+cast(JPP_RRepWait as varchar(20))+';'
		+cast(JPP_RElse as varchar(20))
 from OH inner join
      JPP on (OH_Idnr = JPP_OH_Idnr)
 where JPP_OType not like '<%'
 and JPP_RElse = '3'
 and JPP_RWhen is not NULL
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name; 

/* 3 Queries added, 12.02.2015, POM */

/* optimization to do: % nicht zu Beginn der Suche - aber wie ändern? */
print 'SAP_SPOOL;>> E: SAP job spool parameter [EXPIR]ATION only allows 1-digit values 1-9 (like SM36) <<' ;   
print 'SAP_SPOOL;Client;Name;Type;Lnr;Content' ;
select 'SAP_SPOOL;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like '%r3_%,%expir%=%'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name,OT_Lnr;

print 'SET_PRINT_DEFAULTS;>> E: SET_PRINT_DEFAULTS must be replaced by R3_SET_PRINT_DEFAULTS <<' ; 
print 'SET_PRINT_DEFAULTS;Client;Object;ScriptType;Lnr;Content' ;     
select 'SET_PRINT_DEFAULTS;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content)     like '%set_print_defaults%'
 and   lower(OT_Content) not like '%r3_set_print_defaults%'
 and   lower(OT_Content) not like '%oa_set_print_defaults%'
 /* and OH_Client <> 0 */
  and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

print 'MODIFY_VARIANT_PARM;>> E: R3_MODIFY_VARIANT using KIND=P does no longer ignore options only defined for KIND=S <<' ; 
print 'MODIFY_VARIANT_PARM;Client;Object;ScriptType;Lnr;Content' ;     
select 'MODIFY_VARIANT_PARM;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like '%r3_modify_variant%'
 and  (lower(OT_Content) like '%kind=p%' or
       lower(OT_Content) like '%kind=''p''%' or
       lower(OT_Content) like '%kind="p"%')
 and  (lower(OT_Content) like '%high=%' or
       lower(OT_Content) like '%sign=%' or
       lower(OT_Content) like '%option=%' or
       lower(OT_Content) like '%mode=%')
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name,OT_Lnr;

print 'RSET_AND_ACTIVATE;>> E: Since V9, RSET script variables also passed to objects using ACTIVATE_UC_OBJECT with PASS_VALUES <<' ; 
print 'RSET_AND_ACTIVATE;Client;Object;ScriptType;Lnr;Content' ;     
select 'RSET_AND_ACTIVATE;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%activate_uc_object%pass_values%'
 and OT_OH_Idnr in (select OT_OH_Idnr from OT where lower(OT_Content) like ':%rset %')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

/* Check for R3_IMPORT_JOBS */
print 'R3IMPORT;>> W: Check for R3_IMPORT_JOBS (SAP Agent and AE has to be on the same version) <<' ;
select 'R3IMPORT;Client;Name;Object type;lnr#;content' ;
select 'R3IMPORT;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where (lower(OT_Content) like ':%r3_import_jobs%')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;
 
/* 1 Query moved from the V9 only section, 12.02.2015, POM */ 
 
print 'OBJ_VARIABLE_VALUES;>> E: Since V9SP5 single apostrophes at the beginng and the end of object variable values, will no longer be automatically removed <<' ;   
print 'OBJ_VARIABLE_VALUES;Client;Object;VarName;VarValue' ;     
select 'OBJ_VARIABLE_VALUES;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OV_VName+';'+OV_Value
 from OH inner join
      OV on (OH_Idnr = OV_OH_Idnr)
 where (OV_Value like '%''%')
 order by OH_Client,OH_Name;  

/* Suche in VARA nach && */
print 'VARA_DOUBLE_AMP;>> E: Use of double ampersant will return less characters <<' ;
print 'VARA_DOUBLE_AMP;Client;Object;VarKey;VarValue' ;
select 'VARA_DOUBLE_AMP;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OVW_VValue+';'+OVW_Value1
 from OH inner join
	  OVW on (OH_Idnr = OVW_OH_Idnr)
 where OVW_Value1 like '%&&%'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name;

/* change in v10SP5: GET_VAR does no longer resolve recursively when reading a VARA object */
print 'VARA_SCRIPTVAR_RECURSIVE;>> E: Use of GET_VAR with a script variable does not resolve recursively anymore <<' ;
print 'VARA_SCRIPTVAR_RECURSIVE;Client;Object;VarKey;VarValue' ;
select 'VARA_SCRIPTVAR_RECURSIVE;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OVW_VValue+';'+OVW_Value1
 from OH inner join
	  OVW on (OH_Idnr = OVW_OH_Idnr)
 where OVW_Value1 like '%&%'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name;

/* following: search for corresponding parameter in UC_SYSTEM_SETTINGS */
print 'VARA_SCRIPTVAR_RECURSIVE_SETTING >> W: UC_SYSTEM_SETTINGS parameter no longer supported. <<' ;
select 'VARA_SCRIPTVAR_RECURSIVE_SETTING;OH_Name;Key;Value'
select 'VARA_SCRIPTVAR_RECURSIVE_SETTING;'+OH_Name+';'+OVW_VValue+';'+OVW_Value1
 from OH inner join
      OVW on (OH_Idnr = OVW_OH_Idnr)
 where lower(OH_Name) = 'uc_system_settings'
 and   lower(OVW_VValue) = 'resolve_get_var'
 and OH_DeleteFlag = 0
 order by OH_Client;
 
/* Liste der Verbindungen per API
   auch das CallPI bzw. ApplicationInterface sollte aktualisiert werden */
print 'CALL_API;>> I: List of Call API connections - CallAPIs can be updated as well (but most are compatible). <<' ;
select 'CALL_API;OH_Name;Idnr;created by'
select 'CALL_API;'+cast(AH_Client as varchar(20))+';'+AH_OType+';'+cast(AH_TimeStamp1 as varchar(20))+';'+
 (select OH_Name from OH where AH_USR_Idnr = OH_Idnr) as 'User'
 from AH
 where lower(AH_OType) like '%api%'
 order by AH_Client,AH_TimeStamp1;

/* Aufruf des CallAPIs in Objekten */
print 'CALL_API_EXE;>> W: list of CallAPI executions in process tabs (probably need to change the path). <<' ;
select 'CALL_API_EXE;OH_Client;OH_Name;OH_Otype; Lnr#;Content'
select 'CALL_API_EXE;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OH_OType+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH
 inner join OT on (OH_Idnr = OT_OH_Idnr)
 and (lower(OT_Content) like '%/callapi%'
 or lower(OT_Content) like '%\callapi%');

/* SERVER_OPTIONS in UC_SYSTEM_SETTINGS
   Stelle 16 (A = Verwendung der alten Server-Aktivierung) wird nicht mehr unterstuetzt */ 
print 'SERVER_OPTIONS;>> W: UC_SYSTEM_SETTINGS 16th character for use of old activation mechanism no longer supported. <<' ;
select 'SERVER_OPTIONS;OH_Name;Key;Value'
select 'SERVER_OPTIONS;'+OH_Name+';'+OVW_VValue+';'+OVW_Value1
 from OH inner join
	  OVW on (OH_Idnr = OVW_OH_Idnr)
 where lower(OH_Name) = 'uc_system_settings'
 and   lower(OVW_VValue) = 'server_options'
 and OH_DeleteFlag = 0
 order by OH_Client;

/* Verwendung von VERSION_MANAGEMENT in UC_CLIENT_SETTINGS */
print 'VERSION_MGMNT;>> I: Use of VERSION_MANAGEMENT in UC_CLIENT_SETTINGS. <<' ;
select 'VERSION_MGMNT;Client;OH_Name;Key;value'
select 'VERSION_MGMNT;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OVW_VValue+';'+OVW_Value1
 from OH inner join
	  OVW on (OH_Idnr = OVW_OH_Idnr)
 where lower(OH_Name) = 'uc_client_settings'
 and   lower(OVW_VValue) = 'version_management'
 and OH_DeleteFlag = 0
 order by OH_Client;

/* Verwendung von UC_OBJECT_* */
print 'UC_OBJECT;>> I: Use of UC_OBJECT_*. <<' ;
select 'UC_OBJECT;Client;OH_Name;creation date'
select 'UC_OBJECT;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OH_CrDate as varchar(20))
 from OH
 where lower(OH_Name) like 'uc_object_%'
 and OH_DeleteFlag = 0
 order by OH_Client;

/* V10 - asynchroner Filetransfer 
   ab Version 10 standardmaessig asynchron durchgefuehrt, was eine Performanceverbesserung bewirkt.
   Konkret wurde der Standardwert der Einstellungen FT_ASYNC_QUIT_* so geaendert, dass FileTransfers asynchron durchgefuehrt werden.
   
   In der Version 9 ergaben die Standardwerte der Einstellungen eine synchrone Durchfuehrung.
   Beim Update auf Version 10 erfolgt keine automatische Umstellung auf asynchron */
print 'HOSTCHAR_FT;>> I: UC_EX_HOSTCHAR - settings for synchronous/asynchronous transfers. <<' ;
select 'HOSTCHAR_FT;OH_Name;Key;Value'
select 'HOSTCHAR_FT;'+OH_Name+';'+OVW_VValue+';'+OVW_Value1
 from OH inner join
	  OVW on (OH_Idnr = OVW_OH_Idnr)
 where lower(OH_Name) like 'uc_hostchar_%'
 and   lower(OVW_VValue) like 'ft_async_%'
 and OH_DeleteFlag = 0
 and OH_Client = 0;

/* verwendete HOSTCHARs */
print 'HOSTCHAR;>> I: UC_EX_HOSTCHAR - list of used host characteristics. <<' ;
select 'HOSTCHAR;OH_Name;Key;Value'
select 'HOSTCHAR;'+OH_Name+';'+OVW_VValue+';'+OVW_Value1
 from OH inner join
	  OVW on (OH_Idnr = OVW_OH_Idnr)
 where lower(OH_Name) = 'uc_ex_hostchar'
 and OH_DeleteFlag = 0
 and OH_Client = 0
 order by OH_Client;

/* Liste aller HOSTCHARs (auch nicht verwendete) */
print 'HOSTCHAR_TOTAL;>> I: UC_EX_HOSTCHAR - list of defined host characteristics. <<' ;
select 'HOSTCHAR_TOTAL;OH_Name;Idnr;created by'
select 'HOSTCHAR_TOTAL;'+OH_Name+';'+cast(OH_Idnr as varchar(20))+cast(OH_CrUserIdnr as varchar(20))
 from OH
 where OH_Client = 0
 and lower(OH_Name) like 'uc_hostchar_%'
 and OH_DeleteFlag = 0
 order by OH_Client;

/* Einstellungen fuer anonyme JOBS und JOBF Starts */
print 'HOSTC_ANON;>> I: UC_EX_HOSTCHAR - anonymous execution of jobs and file transfers. <<' ;
select 'HOSTC_ANON;Name;UC_Hostchar_xxx;parameter';
select 'HOSTC_ANON;'+OH_Name+';'+OVW_VValue+';'+OVW_Value1
 from OH inner join 
	  OVW on (OH_Idnr = OVW_OH_Idnr)
 where lower(OH_Name) like 'uc_hostchar_%'
 and lower(OVW_VValue) like 'anonymous_%'
 and OH_Client = 0
 and OH_DeleteFlag = 0;

/* Anzahl Datensaetze */
print 'TABLE_ROWS_XX;>> I: TABLE_ROWS - number of objects, reports, ... <<' ;
select 'TABLE_ROWS_XX;Client;count'
select 'TABLE_ROWS_OH;'+cast(OH_Client as varchar(20))+';'+cast(count(1) as varchar(20))
-- select OH_Client, count(1) as '#'
	from OH
	group by OH_Client;
select 'TABLE_ROWS_AH;'+cast(AH_Client as varchar(20))+';'+cast(count(1) as varchar(20))
	from AH
	group by AH_Client;
select 'TABLE_ROWS_RH;'+cast(RH_Client as varchar(20))+';'+cast(count(1) as varchar(20))
	from RH
	group by RH_Client;
select 'TABLE_ROWS_RT;'+cast(AH_Client as varchar(20))+';'+cast(count(1) as varchar(20))
	from RT inner join
		 AH on (RT_AH_Idnr = AH_Idnr)
	group by AH_Client;

/* License information */
print 'LICENSE;>> I: licence data. <<' ;
select 'LICENSE;Platform;Class;Category;Date;Number;Volume1;Restriction';
select 'LICENSE;'+LIC_Platform+';'+LIC_Class+';'+LIC_Category+';'+cast(isnull(LIC_Date,'') as varchar(20))+';'+
 cast(LIC_Number as varchar(20))+';'+cast(LIC_Volume1 as varchar(20))+';'+isnull(LIC_Restriction,'')
 from UC_LIC;

/* List of Agents and Server processes */
print 'AGENTS;>> I: Agents and server processes. <<' ;
select 'AGENTS;Agent;AE/UC4 Version;SW;SWVers;HW;TcpIp Addr;Port;Category;Cls';
select 'AGENTS;'+OH_Name+';'+isnull(HOST_Version,'')+';'+isnull(HOST_HTYP_SW,'')+';'+
       isnull(HOST_HTYP_SWVers,'')+';'+isnull(HOST_HTYP_HW,'')+';'+isnull(HOST_TcpIpAddr,'')+';'+
       cast(isnull(HOST_TcpIpPort,'') as varchar(20))+';'+isnull(HOST_LicCategory,'')+';'+isnull(HOST_LicenceClass,'')
 from OH inner join
      HOST on (OH_Idnr = HOST_OH_Idnr)
 where OH_Name not like '<%>'
 and OH_Deleteflag = 0
 order by OH_Name;

/* current UC4/AE version */
print '>> I: UC_VERSI current AE version. <<' ;
select top (1) 'UC4-VERSION;'+cast(VERSI_Major as varchar(20))+';'+cast(VERSI_Minor as varchar(20))+';'+VERSI_DBVersion
 from UC_VERSI
 order by VERSI_Major desc;

/* last User session */
print 'LAST_LOGON_USERS;>> I: User last logon information. <<' ;
select 'LAST_LOGON_USERS;Client;Name;first name;last name;last logon' ;
select 'LAST_LOGON_USERS;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+isnull(USR_FirstName, '')+';'+isnull(USR_LastName, '')+';'+
  case 
    when USR_LastSession IS NULL then '-'
	else cast(USR_LastSession as varchar(20))
  end 'last session'
 from USR inner join
      OH on (OH_Idnr = USR_OH_Idnr)
 order by OH_Client,OH_Name;

/* old statement
select 'LAST_LOGON_USERS;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+USR_FirstName+';'+USR_LastName+';'+cast(USR_LastSession as varchar(20))
 from OH inner join
      USR on (OH_Idnr = USR_OH_Idnr) inner join
	  INI on (USR_OH_Idnr = INI_Idnr)
 where INI_Section = 'WINDOWS'
 order by OH_Client,OH_Name; */
 
/* List of clients defined */
print 'CLIENTS;>> I: Client list. <<' ;
select 'CLIENTS;Client;Title;TZ assigned' ;
select 'CLIENTS;'+OH_Name+';'+OH_Title+';'+OH_TZ
 from OH
 where (OH_OType = 'CLNT')
 and   (OH_Name <> 'CLNT')
 order by OH_Client;
 
/* full list of Users and UserGroup objects
   Berechtigungen kontrollieren; evtl QUEUE beruecksichtigen */
print 'USERS;>> I: Defined users and user groups. <<' ;
select 'USERS;Client;Name;Object type' ;
select 'USERS;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OH_OType
 from OH
 where OH_OType in ('USER', 'USRG')
 -- and (OH_Name not like '%.OLD.%')
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name;

/* List of Users without UserGroup assignment */
print 'USERS_NO_GROUP;>> I: Defined users without user group assignment. <<' ;
select 'USERS_NO_GROUP;Client;Name;User name' ;
select 'USERS_NO_GROUP;'+cast(OH_Client as varchar(20))+';'+OH_Name
	from USR inner join
         OH on (OH_Idnr = USR_OH_Idnr)
	where USR_OH_Idnr not in (select USRG_USR_Idnr from USRG)
	and OH_DeleteFlag = 0
	order by OH_Client, OH_Name;

/* List of user <-> group relationships (also showing null assignments) */
print 'USER_USRG;>> I: Defined user groups with user assignment. <<' ;
select 'USER_USRG;Client;Name;User assigned' ;
select 'USER_USRG;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+isnull((select OH_Name from OH where OH_Idnr = USRG_USR_Idnr),'-') as UserAssigned
/* select OH_Client, OH_Name, (select OH_Name from OH where OH_Idnr = USRG_USR_Idnr) */
	from USRG full join
	     OH on (OH_Idnr = USRG_USG_Idnr)
	where OH_DeleteFlag = 0
	and OH_OType = 'USRG'
	order by OH_Client, OH_Name, UserAssigned;

/* Authorization tab of user objects
print '>> I: Authorization tab of user objects. <<' ;
select 'USER_AUTH;Client;User name;Grp.;Type;Obj.type;Obj.name;Host (S);Login (S);Filename (S);Host (D);Login (D);Filename (D);UACL_Bit' ;
select 'USER_AUTH;'+cast(OH_Client as varchar(20))+';'+(select OH_Name from OH where OH_Idnr = USR_OH_Idnr) 'User name',
   UACL_Lnr 'Lnr#',
   case UACL_AuthLevel
     when 0 then 'NOT'
	 else cast(UACL_AuthLevel as varchar(20))
   end 'Grp.',
   isnull(UACL_Filter0, '-') 'Type',
   UACL_Filter1 'Obj.type', UACL_Filter2 'Obj.name',
   UACL_Filter3 'Host (S)', UACL_Filter4 'Login (S)', UACL_Filter5 'Filename (S)',
   UACL_Filter6 'Host (D)', UACL_Filter7 'Login (D)', UACL_Filter8 'Filename (D)',
   UACL_BitCode
	from USR inner join OH on (OH_Idnr = USR_OH_Idnr)
		     inner join UACL on (OH_Idnr = UACL_OH_Idnr)
	where OH_DeleteFlag = 0
	and OH_Idnr >= 100000
	order by OH_Client, OH_Name; */

/* Authorization tab of user and usergroup objects */
print 'USRG_AUTH;>> I: Authorization tab of user and usergroup objects. <<' ;
select 'USRG_AUTH;Client;User name;Grp.;Type;Obj.type;Obj.name;Host (S);Login (S);Filename (S);Host (D);Login (D);Filename (D);UACL_Bit' ;
select 'USRG_AUTH;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OH_OType,
   UACL_Lnr 'Lnr#',
   case UACL_AuthLevel
     when 0 then 'NOT'
	 else cast(UACL_AuthLevel as varchar(20))
   end 'Grp.',
   isnull(UACL_Filter0, '-') 'Type',
   UACL_Filter1 'Obj.type', UACL_Filter2 'Obj.name',
   UACL_Filter3 'Host (S)', UACL_Filter4 'Login (S)', UACL_Filter5 'Filename (S)',
   UACL_Filter6 'Host (D)', UACL_Filter7 'Login (D)', UACL_Filter8 'Filename (D)',
   case UACL_BitCode
     when 255 then 'full'
	 else cast(UACL_BitCode as varchar(20))
   end
	from OH inner join UACL on (OH_Idnr = UACL_OH_Idnr)
	where OH_DeleteFlag = 0
	and OH_OType in ('USER','USRG')
	and OH_Idnr >= 100000
	order by OH_Client, OH_Name, UACL_Lnr;

/* Privileges tab of user objects */
print 'USER_PRIV;>> I: Privileges tab of user objects. <<' ;
select 'USER_PRIV;Client;User name;Privileges' ;
select 'USER_PRIV;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+
   case USR_Privilege
     when 0 then 'not assigned'
	 else cast(USR_Privilege as varchar(20))
   end 'Privilege'
   from USR inner join
        OH on (OH_Idnr = USR_OH_Idnr)
	where OH_DeleteFlag = 0
	and OH_Idnr >= 100000
	order by OH_Client, OH_Name;

/* Privileges tab of user group objects */
print 'USRG_PRIV;>> I: Privileges tab of user group objects. <<' ;
select 'USRG_PRIV;Client;User name;Privileges' ;
select 'USRG_PRIV;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+
   case USG_Privilege
     when 0 then 'not assigned'
	 else cast(USG_Privilege as varchar(20))
   end 'Privilege'
   from USG inner join
        OH on (OH_Idnr = USG_OH_Idnr)
	where OH_DeleteFlag = 0
	and OH_Idnr >= 100000
	order by OH_Client, OH_Name;

/* Systemincludes, benoetigt in v10 fuer JOBP Pre-/PostCondition
   -> Berechtigungen kontrollieren; evtl beruecksichtigen */
print '>> I: New invisible system includes in client 0000 used by pre-/post- conditions may need to be authorized. <<' ;
select OH_Name from OH
	where lower(OH_name) like 'xc_inc.%'; 

/* Check script variable names longer than 31 characters
   !! this is the first part - the analysis of this output is done by GP !! */
print 'LENGTH31;>> W: Check for script variable names which may execeed 31 characters in length (additional AE script execution required) <<' ;
select 'LENGTH31;Client;Name;Object type;lnr#;content' ;
select 'LENGTH31;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where (lower(OT_Content) like ':%set%&%'
 or    (lower(OT_Content) like ':%read %&%')
 or    (lower(OT_Content) like ':% process %'))
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

/* WORK IN PROGRESS: neue Suche nach P/RSET
select 'LENGTH31;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where (lower(OT_Content) like ':%[pr]set%&%')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;
*/
 

 
/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   Below this line there are some additional queries that might be interesting ...
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* ======================================================
   jetzt folgen informative Abfragen, wie obsolete Funktionen, Lizenz, ... */

/* ---------- V9 only ------------ */

/*  Prüfung der Registerkarte "Values & Prompts" (v9 ff) */
print '>> E: Check of tab "Values & Prompts" (updates from V9 to newer versions only) <<' ;   
select OH_Client,OH_Name,OV_VName
 from OH inner join
      OV on (OH_Idnr = OV_OH_Idnr)
 where OV_VName like '%&#%'
 and OH_DeleteFlag = 0
/* and OH_Client <> 0 */
 order by OH_Client,OH_Name;

/* Prüfung der PostCondition auf inkorrekte Konfiguration
   Syntax ab v9, behoben mit v10SP5 */
select AH_Client,AH_Name,RT_AH_Idnr,RT_Type,RT_MsgNr,RT_MsgInsert
 from RT,AH
 where AH_Idnr = RT_AH_Idnr
 and RT_MsgNr = '21300';

select OH_Client,OH_Name,JPPO_CarName,JPPO_Type,JPPO_Active,JPPO_Once,JPOV_Value
 from JPPO,OH,JPOV
 where OH_Idnr = JPPO_OH_Idnr
 and JPOV_OH_Idnr = OH_Idnr
 and lower (JPPO_Carname) = 'cancel process flow'
 and JPPO_Location = 2
 and JPOV_Location = 2
 and JPOV_Value like '<%>';
/* ---------- End V9 only ------------ */

/* ---------- V10 to V10  only ------- */

/* Prüfung auf die Script-Funktion CONV_DATE, welche mit v10SP3 nun wieder
   ein 2-stelliges Resultat liefert, siehe V10SP3 Release Notes in der Hilfe */
print '>> E: Script function CONV_DATE has been changed with V10SP2 which has been reverted with V10SP3 (Only relevant for update from V10SP2 to V10SP3!) <<' ;
select 'CONV_DATE;Client;Name;Object type;lnr#;content' ;
select 'CONV_DATE;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where (lower(OT_Content) like ':%=%conv_date%')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;
 
/* -------- End V10 to V10 only */ -------------------------------- 

/* Additional Status Check */

/* nicht mehr gültige STATUS-Namen suchen, falls der Kunde ein zu altes System verwendet.
   Alternative zur Fehlerbereinigung ist, die aktuelle v8 zu installieren und DB.Load durchzuführen */
print '>> E: Status values ENDED_OK_OR_INAKTIV and ENDED_INAKTIV must be changed to ENDED_OK_OR_INACTIV and ENDED_INACTIV <<' ;   
select AH_Client,AH_Name,AJPPA_When from AH,AJPPA
 where AH_Idnr = AJPPA_AH_Idnr
 and AJPPA_When like 'ENDED%INAKTIV';
  
select EH_Client,EH_Name,EJPPA_When from EH,EJPPA
 where EH_AH_IDNR = EJPPA_AH_IDNR
 and EJPPA_When like 'ENDED%INAKTIV';
  
select FE_Name,FJPPA_When from FE,FJPPA
 where FE_Idnr = FJPPA_FE_Idnr
 and FJPPA_When like 'ENDED%INAKTIV';

select OH_Client, OH_Name,JPPA_When from OH,JPPA
 where OH_Idnr = JPPA_OH_Idnr
 and JPPA_When like 'ENDED%INAKTIV';

select OH_Client, OH_Name,JPA_DeactWhen from OH,JPA
 where OH_Idnr = JPA_OH_Idnr
 and JPA_DeactWhen like 'ENDED%INAKTIV';

select OH_Client, OH_Name,JPA_RWhen from OH,JPA
 where OH_Idnr = JPA_OH_Idnr
 and JPA_RWhen like 'ENDED%INAKTIV';

select OH_Client, OH_Name,OSA_RWhen from OH,OSA
 where OH_Idnr = OSA_OH_Idnr
 and OSA_RWhen like 'ENDED%INAKTIV';

select OH_Client,OH_Name,JPP_ExtWhen from OH,JPP
 where OH_Idnr = JPP_OH_Idnr
 and JPP_ExtWhen like 'ENDED%INAKTIV';

select OH_Client,OH_Name,JPP_RWhen from OH,JPP
 where OH_Idnr = JPP_OH_Idnr
 and JPP_RWhen like 'ENDED%INAKTIV';

select OH_Client,OH_Name,JBA_DeactWhen from OH,JBA
 where OH_Idnr = JBA_OH_Idnr
 and JBA_DeactWhen like 'ENDED%INAKTIV';

select OH_Client,OH_Name,EJPP_RWhen from AH,EJPP,OH
 where AH_Idnr = EJPP_AH_Idnr
 and OH_Idnr = AH_OH_Idnr
 and EJPP_RWhen like 'ENDED%INAKTIV';

select OH_Client,OH_Name,EJPP_ExtWhen from AH,EJPP,OH
 where AH_Idnr = EJPP_AH_Idnr
 and OH_Idnr = AH_OH_Idnr
 and EJPP_ExtWhen like 'ENDED%INAKTIV';

/* Statements to correct the invalid status names can be found in the DB.Load script
-> Only use if appropriate!
update ajppa set ajppa_when = 'ENDED_OK_OR_INACTIV' where ajppa_when = 'ENDED_OK_OR_INAKTIV';
update ajppa set ajppa_when = 'ENDED_INACTIV' where ajppa_when = 'ENDED_INAKTIV';

update ejppa set ejppa_when = 'ENDED_OK_OR_INACTIV' where ejppa_when = 'ENDED_OK_OR_INAKTIV';
update ejppa set ejppa_when = 'ENDED_INACTIV' where ejppa_when = 'ENDED_INAKTIV';

update fjppa set fjppa_when = 'ENDED_OK_OR_INACTIV' where fjppa_when = 'ENDED_OK_OR_INAKTIV';
update fjppa set fjppa_when = 'ENDED_INACTIV' where fjppa_when = 'ENDED_INAKTIV';

update jppa set jppa_when = 'ENDED_OK_OR_INACTIV' where jppa_when = 'ENDED_OK_OR_INAKTIV';
update jppa set jppa_when = 'ENDED_INACTIV' where jppa_when = 'ENDED_INAKTIV';

update jpa set jpa_deactwhen = 'ENDED_OK_OR_INACTIV' where jpa_deactwhen = 'ENDED_OK_OR_INAKTIV';
update jpa set jpa_deactwhen = 'ENDED_INACTIV' where jpa_deactwhen = 'ENDED_INAKTIV';

update jpa set jpa_rwhen = 'ENDED_OK_OR_INACTIV' where jpa_rwhen = 'ENDED_OK_OR_INAKTIV';
update jpa set jpa_rwhen = 'ENDED_INACTIV' where jpa_rwhen = 'ENDED_INAKTIV';

update osa set osa_rwhen = 'ENDED_OK_OR_INACTIV' where osa_rwhen = 'ENDED_OK_OR_INAKTIV';
update osa set osa_rwhen = 'ENDED_INACTIV' where osa_rwhen = 'ENDED_INAKTIV';

update jpp set jpp_extwhen = 'ENDED_INACTIV' where jpp_extwhen = 'ENDED_INAKTIV';
update jpp set jpp_extwhen = 'ENDED_OK_OR_INACTIV' where jpp_extwhen = 'ENDED_OK_OR_INAKTIV';

update jpp set jpp_rwhen = 'ENDED_OK_OR_INACTIV' where jpp_rwhen = 'ENDED_OK_OR_INAKTIV';
update jpp set jpp_rwhen = 'ENDED_INACTIV' where jpp_rwhen = 'ENDED_INAKTIV';

update jba set jba_deactwhen = 'ENDED_OK_OR_INACTIV' where jba_deactwhen = 'ENDED_OK_OR_INAKTIV';
update jba set jba_deactwhen = 'ENDED_INACTIV' where jba_deactwhen = 'ENDED_INAKTIV';

update ejpp set ejpp_rwhen = 'ENDED_OK_OR_INACTIV' where ejpp_rwhen = 'ENDED_OK_OR_INAKTIV';
update ejpp set ejpp_rwhen = 'ENDED_INACTIV' where ejpp_rwhen = 'ENDED_INAKTIV';

update ejpp set ejpp_extwhen = 'ENDED_OK_OR_INACTIV' where ejpp_extwhen = 'ENDED_OK_OR_INAKTIV';
update ejpp set ejpp_extwhen = 'ENDED_INACTIV' where ejpp_extwhen = 'ENDED_INAKTIV'; */

/* ------- End Additional Status Check ---------------------- */

/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

/* various obsolete Functions and Commands */

print '>> I: Use of obsolete script functions and commands. <<' ;
select 'OBSOLETE1;Client;Name;Object type;lnr#;content' ;
select 'OBSOLETE1;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
	  OH on (OT_OH_Idnr = OH_Idnr)
 where (lower(OT_Content) like ':%=%cint%(%)%'
  or    lower(OT_Content) like ':%=%cstr%(%)%'
  or    lower(OT_Content) like ':%=%sys_act_jpname%'
  or    lower(OT_Content) like ':%=%sys_act_jpnr%'
  or    lower(OT_Content) like ':%=%sys_act_jobname%'
  or    lower(OT_Content) like ':%=%sys_act_jobnr%'
  or    lower(OT_Content) like ':%replace_jp_structure%'
  or    lower(OT_Content) like ':%set_uc_setting%'
  or    lower(OT_Content) like ':%xml_close_docu%'
  or    lower(OT_Content) like ':%=%prep_process_hostgroup%'
  or    lower(OT_Content) like ':%=%xml_open_docu%')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

select 'OBSOLETE2;Client;Name;Object type;lnr#;content' ;
select 'OBSOLETE2;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
	  OH on (OT_OH_Idnr = OH_Idnr)
 where (lower(OT_Content) like ':%=%sys_state_activ%(%)%'
  and   lower(OT_Content) not like ':%=%sys_state_active%(%)%')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr;

/* PREP_PROCESS_VAR - general use */
print '>> I: Use of PREP_PROCESS_VAR. <<' ;
select 'PP_VAR;Client;Name;Object type;lnr#;content' ;  
select 'PP_VAR;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%prep_process_var%'
 and OH_DeleteFlag = 0
 order by OH_Client;

/* JOBP - Result tab - general use */
select 'RESULT_GENERAL;>> I: RESULT tab in workflows - General use. <<' ; 
select 'RESULT_GENERAL;Client;JPName;OKStatus;RepeatCnt;Execute;Else' ;  
select 'RESULT_GENERAL;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+JPP_RWhen+';'+cast(JPP_RRepMTimes as varchar(20))+';'+JPP_RExecute+';'+cast(JPP_RElse as varchar(20))
 from OH inner join
     JPP on (OH_Idnr = JPP_OH_Idnr)
 where JPP_RWhen is not NULL
 and OH_DeleteFlag = 0
 and OH_Client <> 0
 order by OH_Client,OH_Name;

/* Objects per client */
print '>> I: objects per client. <<' ;
select 'OBJECTS_CLIENT;Client;Object type;#' ; 
select 'OBJECTS_CLIENT;'+cast(OH_Client as varchar(20))+';'+OH_OType+';'+cast(count(1) as varchar(20))
 from OH
 where OH_DeleteFlag = 0
 group by OH_Client,OH_OType;
  -- order by OH_Client,OH_Name;

/* READ - general use */
select 'READ_GENERAL;>> I: READ statement - general use. <<' ; 
select 'READ_GENERAL;Client;OH_Name;Lnr#;content' ;  
select 'READ_GENERAL;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH left join
      OT on (OH_Idnr = OT_OH_Idnr)
 where lower(OT_Content) like ':%read%,%,%,%,%,%,%k%'
 and OH_Idnr > 100000
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name;

/* Objects grouped by OH_DeleteFlag */
print '>> I: objects in Recycly bin. <<' ;
select 'DELETE_FLAG;Client;OH_DeleteFlag;#' ; 
select 'DELETE_FLAG;'+cast(OH_Client as varchar(20))+';'+
 case
  when OH_DeleteFlag = 1 then '1 - recycle bin'
  when OH_DeleteFlag = 2 then '2 - old version'
  else cast(OH_DeleteFlag as varchar (20))
 end 
  +';'+cast(count(1) as varchar(20))
 from OH
 where OH_DeleteFlag <> 0
 group by OH_Client, OH_DeleteFlag; 

/* Objects flagged by Archive and Reorg  */
print '>> I: AH with Archive/Delete flag set. <<' ;
select 'ARCH_FLAG_AH;Client;Object name;Archive flag;Delete flag' ; 
select 'ARCH_FLAG_AH;'+cast(AH_Client as varchar(20))+';'+AH_Name+';'+AH_OType+';'+
 cast(AH_ArchiveFlag as varchar(20))+';'+cast(AH_DeleteFlag as varchar(20))+';'+
 cast(AH_TimeStamp1 as varchar(20))
 from AH
 where ((AH_DeleteFlag = 1) or (AH_ArchiveFlag = 1))
 order by AH_Client, AH_Name;
 -- order by OH_Client,OH_Name;

print '>> I: RH with Archive/Delete flag set. <<' ;
select 'ARCH_FLAG_RH;Client;Object name;Archive flag;Delete flag' ; 
select 'ARCH_FLAG_RH;'+cast(RH_Client as varchar(20))+';'+RH_Type+';'+
 cast(RH_ArchiveFlag as varchar(20))+';'+
 cast(RH_DeleteFlag as varchar(20))+';'+
 cast(isnull(RH_TimeStamp4,0) as varchar(20))
 from RH
 where ((RH_DeleteFlag = 1) or (RH_ArchiveFlag = 1))
 order by RH_Client, RH_Title;

print '>> I: MELD with Archive/Delete flag set. <<' ;
select 'ARCH_FLAG_MELD;Client;msg read;Archive flag;Delete flag'; 
select 'ARCH_FLAG_MELD;'+cast(MELD_Client as varchar(20))+';'+
 cast(MELD_TimeStamp as varchar(20))+';'+
 cast(MELD_ArchiveFlag as varchar(20))+';'+
 cast(MELD_DeleteFlag as varchar(20))
 from MELD
 where ((MELD_DeleteFlag = 1) or (MELD_ArchiveFlag = 1))
 order by MELD_Client, MELD_TimeStamp;

/* Objects in Recycle bin */
print '>> I: objects in Recycly bin. <<' ;
select 'RECYCLE_BIN;Client;Object name Object type; Delete date (UTC)' ; 
select 'RECYCLE_BIN;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+OH_OType+';'+cast(OH_ModDate as varchar(20))
 from OH
 where OH_DeleteFlag = 1
 order by OH_Client, OH_Name;

/* linked Objects - important to recreate Favorites and UserGroup Links */
print '>> I: object links <<' ;
select 'OBJ_LINKS;Client;ObjTyp;ObjectName;Folder;ObjTitle;OFS_Level';
select 'OBJ_LINKS', OH_Client, OH_OType, OH_Name, 
(select OH_Name from OH where OH_Idnr = OFS_Idnr), OH_Title, OFS_Level
 from OFS
 inner join OH on (OFS_OH_Idnr_O = OH_Idnr)
 where OFS_Link = 1
 and OH_OType <> 'FOLD'
 and upper(OH_Name) not like 'PCK.AUTOMIC_%'
 order by OH_Client, OH_OType, OH_Name;


/* v11.1/11.2 compatibility checks

Rückfragen an: peter.grundler@automic.com

2015.05.13: Suche nach Verwendung von "U"-Meldungsnummern in Script/VARA/FILTER
			DB-Struktur hat sich geändert: Suche in SQL/SQLI/SQLJOBS
			GET_OH_IDNR: 2nd parameter "client" was removed due to security reasons 
			
2015.05.21: GET_ATT_SUBSTR
			GET_VAR does not resolve recursively anymore
			
2015.10.03: some adoptions for the search of message numbers "Uxxx"

2016.08.16: removed search for OH_Name like %.OLD.% because covered by OH_DeleteFlag = 0

2018.09.26: SET_SCRIPT_VAR does no longer add '#' at the end of the script variable

*/

/* old version
select OH_Client,OH_Name,OH_OType, OT_Lnr,OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where (lower(OT_Content) like ':%u0%'
 or lower(OT_Content) like ':%u1%'
 or lower(OT_Content) like ':%u2%'
 or lower(OT_Content) like ':%u3%'
 or lower(OT_Content) like ':%u4%'
 or lower(OT_Content) like ':%u5%'
 or lower(OT_Content) like ':%u6%'
 or lower(OT_Content) like ':%u7%'
 or lower(OT_Content) like ':%u8%')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 and OH_Name not like '%.OLD.%'
 order by OH_Client,OH_Name,OT_Lnr; */

/* change in v11.2:
 With v9, :SET_SCRIPT_VAR did some automatic processing of the variable name stored in the value of the
  variable passed to the script statement:
  .) if a leading ampersand  (&) is present, ignore it — in other words, do not perform variable resolution.
  .) if a trailing hash (#) is not present, add one to the end of the variable name(in most cases).
  With v11.2, :SET_SCRIPT_VAR does neither of these things */
print 'SET_SCRIPT_VAR;>> E: SET_SCRIPT_VAR does no longer automatic processing of the variable name <<' ;
print 'SET_SCRIPT_VAR;Client;Name;Object type;lnr#;content' ;
select 'SET_SCRIPT_VAR'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where (lower(OT_Content) like ':%set_script_var%')
 and OH_DeleteFlag = 0
 /* and OH_Client <> 0 */
 and OH_Idnr >= 100000
 order by OH_Client,OH_Name,OT_Lnr; 

print 'MSGNR_SCRIPT;>> E: search for Message numbers in script tabs. <<' ;
print 'MSGNR_SCRIPT;Client;Name;Object type;lnr#;content' ;
select cast(OH_Client as varchar)+';'+OH_Name+';'+OH_OType+';'+cast(OT_Lnr as varchar)+';'+OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where (lower(OT_Content) like ':%U[0-9][0-9][0-9][0-9][0-9][0-9][0-9]%')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%'
 order by OH_Client,OH_Name,OT_Lnr;

print 'MSGNR_FILTER;>> E: search for Message numbers in FILTER objects. <<' ;
/* old version
select OH_Client,OH_Name,OH_OType, OFC_Lnr,OFC_SrcType,OFC_SrcName, OFC_FilterText
 from OH inner join
      OFC on (OH_Idnr = OFC_OH_Idnr)
where (lower(OFC_FilterText) like '%u0%'
 or lower(OFC_FilterText) like '%u1%'
 or lower(OFC_FilterText) like '%u2%'
 or lower(OFC_FilterText) like '%u3%'
 or lower(OFC_FilterText) like '%u4%'
 or lower(OFC_FilterText) like '%u5%'
 or lower(OFC_FilterText) like '%u6%'
 or lower(OFC_FilterText) like '%u7%'
 or lower(OFC_FilterText) like '%u8%')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 and OH_Name not like '%.OLD.%' 
 order by OH_Client,OH_Name; */

select cast(OH_Client as varchar)+';'+OH_Name+';'+OH_OType+';'+cast(OFC_Lnr as varchar)+';'+OFC_SrcType+';'+OFC_SrcName+';'+OFC_FilterText
 from OH inner join
      OFC on (OH_Idnr = OFC_OH_Idnr)
where (lower(OFC_FilterText) like '%U[0-9][0-9][0-9][0-9][0-9][0-9][0-9]%')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%' 
 order by OH_Client,OH_Name;

/* Syntax valid for v9 and higher */
print 'MSGNR_VARA;>> E: search for Message numbers in VARIABLE objects. <<' ;
select OH_Client,OH_Name,OVW_VValue,OVW_Value1
 from OH inner join
	  OVW on (OH_Idnr = OVW_OH_Idnr)
 where (lower(OVW_Value1) like '%u0%' or lower(OVW_VValue) like '%u0%'
 or     lower(OVW_Value1) like '%u1%' or lower(OVW_VValue) like '%u1%'
 or     lower(OVW_Value1) like '%u2%' or lower(OVW_VValue) like '%u2%'
 or     lower(OVW_Value1) like '%u3%' or lower(OVW_VValue) like '%u3%'
 or     lower(OVW_Value1) like '%u4%' or lower(OVW_VValue) like '%u4%'
 or     lower(OVW_Value1) like '%u5%' or lower(OVW_VValue) like '%u5%'
 or     lower(OVW_Value1) like '%u6%' or lower(OVW_VValue) like '%u6%'
 or     lower(OVW_Value1) like '%u7%' or lower(OVW_VValue) like '%u7%'
 or     lower(OVW_Value1) like '%u8%' or lower(OVW_VValue) like '%u8%')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%' 
 order by OH_Client,OH_Name;

print 'SQL_JOBS;>> I: search for SQL statements in JOBS objects. <<' ;
select OH_Client,OH_Name,OH_OType,OT_Lnr,OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where (lower(OT_Content) like 'select'
 or  lower(OT_Content) like 'insert'
 or  lower(OT_Content) like 'update'
 or  lower(OT_Content) like 'alter')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%' 
 order by OH_Client,OH_Name,OT_Lnr;

/* Syntax valid for v9 and higher */
print 'SQL_VARA;>> I: search for SQL statements in VARA objects. <<' ;
select OH_Client,OH_Name,OVD_Source,OVD_Sql,OVD_SqlOra,OVD_SqlDB2
 from OH inner join
      OVD on (OH_Idnr = OVD_OH_Idnr)
 where lower(OVD_Source) like '%sql%'
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 and OH_OType = 'VARA'
 --and OH_Name not like '%.OLD.%' 
 order by OH_Client,OH_Name;

print 'GET_OH_IDNR;>> E: 2nd parameter was removed. <<' ;
select OH_Client,OH_Name,OH_OType,OT_Lnr,OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where lower(OT_Content) like '%get_oh_idnr%'
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%' 
 order by OH_Client,OH_Name,OT_Lnr;

/* In previous AE versions, at least a blank was returned. Since v11, no value in case of missing call text is returned. */
print 'GET_ATT_SUBSTR;>> E: Error occurs on empty call text. <<' ;
select OH_Client,OH_Name,OH_OType,OT_Lnr,OT_Content
 from OH inner join
      OT on (OH_Idnr = OT_OH_Idnr)
 where lower(OT_Content) like '%get_att_substr%'
 and OH_OType = 'CALL'
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%' 
 order by OH_Client,OH_Name,OT_Lnr;

/* RESOLVE_GET_VAR in UC_SYSTEM_SETTINGS
   introduced with v10 SP4 HF1 and removed in v11 -> use the script function RESOLVE_VAR instead */
print 'RESOLVE_GET_VAR;>> W: RESOLVE_GET_VAR no longer supported. <<' ;
select OH_Client,OH_Name,OVW_VValue,OVW_Value1
 from OH inner join
      OVW on (OH_Idnr = OVW_OH_Idnr)
 where lower(OH_Name) = 'uc_system_settings'
 and lower(OVW_VValue) = 'resolve_get_var'
 and OH_Client = 0
 and OH_DeleteFlag = 0;

/* v9 and v10 only */
/* GET_VAR does not resolve recursively anymore
   From version v9 SP4 to v10 SP4, GET_VAR resolves recursively */
print 'GET_VAR_RECURS;>> W: GET_VAR does not resolve recursively anymore. <<' ;
select OH_Client,OH_Name,OVW_Value1,OVW_Value2,OVW_Value3,OVW_Value4,OVW_Value5
 from OH inner join
      OVW on (OH_Idnr = OVW_OH_Idnr)
 where ((OVW_Value1 like '%&%')
 or     (OVW_Value2 like '%&%')
 or     (OVW_Value3 like '%&%')
 or     (OVW_Value4 like '%&%')
 or     (OVW_Value5 like '%&%'))	  
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%'
 order by OH_Client,OH_Name;

/* Deactivation behaviour/display behaviour of tasks with status FAULT_OTHER has been changed */
print 'OBJ_DEACT_JOBS;>> W: deactivation of JOBS <<' ;
select OH_Client,OH_Name,JBA_AutoDeact
 from OH inner join
      JBA on (OH_Idnr = JBA_OH_Idnr)
 where JBA_AutoDeact not in ('A','N')	  
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%'
 order by OH_Client,OH_Name;	

print 'OBJ_DEACT_JOBF;>> W: deactivation of JOBF <<' ; 
select OH_Client,OH_Name,JFA_AutoDeact
 from OH inner join
      JFA on (OH_Idnr = JFA_OH_Idnr)
 where JFA_AutoDeact not in ('A','N')	  
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%'
 order by OH_Client,OH_Name;

print 'OBJ_DEACT_JOBP;>> W: deactivation of JOBP <<' ;
select OH_Client,OH_Name,JPA_AutoDeact
 from OH inner join
      JPA on (OH_Idnr = JPA_OH_Idnr)
 where JPA_AutoDeact not in ('A','N')
 and OH_DeleteFlag = 0
 and OH_Idnr >= 100000
 --and OH_Name not like '%.OLD.%'
 order by OH_Client,OH_Name;

print 'STAT_FAULT_OTHER;>> I: list of FAULT_OTHER in statistics <<' ;
print 'STAT_FAULT_OTHER;Client;Object;ObjType;Aktivierung;Runnr' ;  
select AH_Client,AH_Name,AH_OType,AH_TimeStamp1,AH_Idnr from AH
 where AH_Status = 1820
 order by AH_Client,AH_Name,AH_TimeStamp1;

/* (c) GP peter.grundler@automic.com

2017.01.31	Change of script function behavior: PREP_PROCESS_FILENAME, PREP_PROCESS_FILE, PREP_PROCESS, GET_FILESYSTEM
			do not abort anymore, if an agent is not available but stay in "Waiting for host" instead.

			Check for existing RA Solutions
			have to be upgraded to newer versions that support AWI.
			All other RA solution do not support AWI and therefore cannot be edited in AWI.
			Objects of other RA solutions cannot be edited in AWI.
 
2018.06.18  search for COCKPIT objects as they are no longer supported with v12.x

2018.09.25: READ - default value can have max. 127 characters				
			
*/

/* search for affected script functions */
print '>> W: change of script function behaviour <<' ;
select 'V12_SCRIPT_AGENTS;Client;Object type;lnr#;content' ; 
select 'V12_SCRIPT_AGENTS;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Type as varchar(20))+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OT inner join
      OH on (OT_OH_Idnr = OH_Idnr)
 where lower(OT_Content) like ':%prep_process_file%'
 or lower(OT_Content) like ':%prep_process %'
 or lower(OT_Content) like ':%get_filesystem%'
 and OH_DeleteFlag = 0
 order by OH_Client;

/* check RA Solutions */
print '>> W: change of script function behaviour <<' ;
select 'V12_RA_SOLUTION;Client;Object type;lnr#;content' ; 
select 'V12_RA_SOLUTION'+';'+OH_Name
 from OH
 where OH_OType = 'CITC'
 and OH_Client = 0
 order by OH_OType;

/* search CPIT objects */
print '>> W: search for COCKPIT objects <<' ;
select 'OBJECTS_CPIT;Client;Object name; last modification date' ; 
select 'OBJECTS_CPIT;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OH_ModDate as varchar(20))
 from OH
 where (OH_Name not like '%.OLD.%')
 and OH_OType = 'CPIT'
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name
 
/*
Webservice agent changes 
 
The new version of the WebService agent (4.0.0) was split into separate RA solutions for SOAP and REST.

All three agents (WebService 3, WebService REST 4, and WebService SOAP 4) can run in parallel.
 The RA solutions of version 4 do not replace the one of version 3.

Existing objects of version 3 are not automatically migrated to objects of version 4.

select 'OBJECTS_CLIENT;'+cast(OH_Client as varchar(20))+';'+OH_OType+';'+cast(count(1) as varchar(20))
 from OH
 where OH_DeleteFlag = 0
 group by OH_Client,OH_OType;
  -- order by OH_Client,OH_Name;
-- end;

*/

/* READ - default value is now limited by 127 characters (up to v11.2: 1024 characters)
   work to to: how to check the length of parameter 4
 */
select 'READ_DEFAULT;>> E: READ statement - default value max length. <<' ; 
select 'READ_DEFAULT;Client;OH_Name;Lnr#;content' ;  
select 'READ_DEFAULT;'+cast(OH_Client as varchar(20))+';'+OH_Name+';'+cast(OT_Lnr as varchar(20))+';'+OT_Content
 from OH left join
      OT on (OH_Idnr = OT_OH_Idnr)
 where lower(OT_Content) like ':%read%,%,%,%,%'
 and OH_Idnr > 100000
 and OH_DeleteFlag = 0
 order by OH_Client,OH_Name;