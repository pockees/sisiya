import java.sql.*;
import java.io.*;
//import java.text.*;
import java.util.*;
import java.net.*;
 
/**
  * SISIYAReport. Generates HTML reports from a SISIYA Database.
  * @version 0.1 20.12.2003
  * @author Erdal MUTLU
  */ 
public class SISIYAReport 
{
 final static String progName="SISIYAReport";
 final static String rbName="SISIYA";
 String dateString; // today as a yyyymmdd string
 int choice=0; // 2^0=serverstatus, 2^1=serverservericestatus, 2^3=serverhistorystatus 2^4=serverhistorystatusall

 /**
   * Default contsructor.
   */
 SISIYAReport()
 {
  dateString=getDateString();
 }

 public static void main(String args[])
  throws SQLException
 {

  if(args.length != 2) {
     System.err.println("Usage   : "+progName+"locale report_choice");
     System.err.println("Example : "+progName+"en 3");
     System.err.println("2^0=serverstatus, 2^1=serverservericestatus, 2^2=serverhistorystatus, 2^3=serverInfo");
     System.exit(1);
  }
  SISIYAReport sisiyareport=new SISIYAReport();

  
  ResourceBundle rb=null;
  String locale_str="null";
  String jdbc_driver_str=null;
  String jdbc_url_str=null;
  String user_str=null;
  String password_str=null;
  String charset_str=null;
  Connection connection=null; 


  locale_str=new String(args[0]);
  sisiyareport.choice=(new Integer(args[1])).intValue();

  Locale locale=new Locale(locale_str,locale_str.toUpperCase());
  rb=ResourceBundle.getBundle(rbName,locale);
  
  jdbc_driver_str=rb.getString(rbName+".jdbc_driver");
  jdbc_url_str=rb.getString(rbName+".jdbc_url");
  user_str=rb.getString(rbName+".user");
  password_str=rb.getString(rbName+".password");
 
  PrintWriter out=new PrintWriter(System.out,true);

  boolean errorFlag=false; 
  try {
      connection=sisiyareport.loginToDB(out,jdbc_driver_str,jdbc_url_str,user_str,password_str); 
  }
  catch(SQLException e) {
      errorFlag=true; 
      out.println(progName+": SQLException caught");
      while(e != null) {
        out.println(progName+": SQL State :"+e.getSQLState());
        out.println(progName+": Message   :"+e.getMessage());
        out.println(progName+": Error Code:"+e.getErrorCode());
        e=e.getNextException();
      }
     }
   catch(ConnectException e) {
      errorFlag=true; 
      out.println(progName+": ConnectException caught");
      out.println(progName+": Message :"+e.getMessage());
   }  
   if(errorFlag) {
   //  System.err.println(progName+": Connection error!");
     return;
   }
  sisiyareport.generateReports(rb,connection);
 }		       
 
 /**
   * loginToDB : Creates a connection to the database.
   */
 public Connection loginToDB(PrintWriter out,String driver,String connect,String user,String password)
  throws SQLException, ConnectException
 {
  Connection conn=null;

  if(conn == null || conn.isClosed())
   {
   // Load the JDBC driver
    try {
       Class.forName(driver).newInstance();  
    }
    catch(Exception E) { 
     out.println("<CENTER><H1><FONT COLOR=\"RED\">Unable to load the "+driver+" JDBC driver</FONT></H1></CENTER>");
     E.printStackTrace();
    }
    conn=DriverManager.getConnection(connect,user,password);
   }
  DatabaseMetaData dbmd=conn.getMetaData();
  /*
  out.println(progName+" :(loginToDB): Database Product Name    : "+dbmd.getDatabaseProductName());
  out.println(progName+" :(loginToDB): Database Product Version : "+dbmd.getDatabaseProductVersion());
  out.println(progName+" :(loginToDB): Driver Name              : "+dbmd.getDriverName());
  out.println(progName+" :(loginToDB): Driver Version           : "+dbmd.getDriverVersion());
  out.println(progName+" :(loginToDB): Driver Major Verion      : "+dbmd.getDriverMajorVersion());
  out.println(progName+" :(loginToDB): Driver Minor Version     : "+dbmd.getDriverMinorVersion());
  */
  return conn;
 }

 /**
   * getChangedString : Generates last change time as a string.
   */
 String getChangedString(Timestamp a,Timestamp b)
 {
  StringBuffer sb=new StringBuffer();
  long seconds,minutes,hours,days;
  long t=(a.getTime()-b.getTime())/1000;

  seconds=t%60;
  t=(int)(t/60);
  minutes=t%60;
  t=(int)(t/60);
  hours=t%24;
  days=(int)(t/24);
  if(days > 0) {
   sb.append(days+" day");
   if(days > 1)
     sb.append("s");
 }
 if(hours > 0) {
   if(sb.length() != 0)
    sb.append(" ");
   sb.append(hours+" hour");
   if(hours > 1)
     sb.append("s");
 }
 if(minutes > 0) {
   if(sb.length() != 0)
    sb.append(" ");
   sb.append(minutes+" minute");
   if(minutes > 1)
     sb.append("s");
 }
 if(seconds > 0) {
   if(sb.length() != 0)
    sb.append(" ");
   sb.append(seconds+" second");
   if(seconds > 1)
     sb.append("s");
 }
 StringBuffer sb2=new StringBuffer("<font color=\"");
 if(days > 5)
   sb2.append("#00FF00\">");
 else if(days > 3)
   sb2.append("#FFFF00\">");
 else
   sb2.append("#FF0000\">");

 sb2.append(sb.toString()+"</font>");
 return sb2.toString(); 

 /* 
  java.sql.Date d=new java.sql.Date(a.getTime()-b.getTime());
  Calendar cal=Calendar.getInstance();
  cal.setTime(d);
  StringBuffer sb=new StringBuffer();
  int x=cal.get(Calendar.YEAR)-1970;
  if(x > 0) {
   sb.append(x+" year");
   if(x > 1)
     sb.append("s");
  }
  x=cal.get(Calendar.MONTH);
  if(x > 0) {
    sb.append(" "+x+" month");
    if(x > 1)
     sb.append("s ");
  }
  x=cal.get(Calendar.DAY_OF_MONTH)-1;
  if(x > 0) {
    sb.append(" "+x+" day");
    if(x > 1)
     sb.append("s ");
  }
  x=cal.get(Calendar.HOUR_OF_DAY);
  if(x > 0) {
    sb.append(" "+x+" hour");
    if(x > 1)
     sb.append("s ");
  }
  x=cal.get(Calendar.MINUTE);
  if(x > 0) {
    sb.append(" "+x+" minute");
    if(x > 1)
     sb.append("s ");
  }
  x=cal.get(Calendar.SECOND);
  if(x > 0) {
    sb.append(" "+x+" second");
    if(x > 1)
     sb.append("s ");
  }




  return(sb.toString());
*/
 }


 /**
   * getDateString : Generates from a Timestamp a yyyymmdd string.
   */
 String getDateString()
 { 
  return(getDateString(Calendar.getInstance()));
 } 
 /**
   * getDateString : Generates from a Timestamp a yyyymmdd string.
   */
 String getDateString(java.util.Date d)
 { 
  Calendar cal=Calendar.getInstance();
  cal.setTime(d);
  return(getDateString(cal));
 } 
 /**
   * getDateString : Generates from a Timestamp a yyyymmdd string.
   */
 String getDateString(Calendar cal)
 { 
  StringBuffer sb=new StringBuffer((new Integer(cal.get(Calendar.YEAR))).toString());
  if((cal.get(Calendar.MONTH)+1) < 10) 
    sb.append("0"+(cal.get(Calendar.MONTH)+1));
  else
    sb.append((cal.get(Calendar.MONTH)+1));
  if(cal.get(Calendar.DAY_OF_MONTH) < 10) 
    sb.append("0"+cal.get(Calendar.DAY_OF_MONTH));
  else
    sb.append(cal.get(Calendar.DAY_OF_MONTH));

  return(sb.toString());
 }

 /**
   * timeString : Generates from a Timestamp a hh:mm:ss dd.mm.yyy string.
   */
 String timeString(Timestamp t)
 { 
  Calendar cal=Calendar.getInstance();
  cal.setTime(t);
  StringBuffer sb=new StringBuffer();
  
  if(cal.get(Calendar.HOUR_OF_DAY) < 10)
    sb.append("0"+cal.get(Calendar.HOUR_OF_DAY));
  else
    sb.append(cal.get(Calendar.HOUR_OF_DAY));
  if(cal.get(Calendar.MINUTE) < 10)
    sb.append(":0"+cal.get(Calendar.MINUTE));
  else
    sb.append(":"+cal.get(Calendar.MINUTE));
  if(cal.get(Calendar.SECOND) < 10)
    sb.append(":0"+cal.get(Calendar.SECOND)+" ");
  else  
    sb.append(":"+cal.get(Calendar.SECOND)+" ");
  if(cal.get(Calendar.DAY_OF_MONTH) < 10) 
    sb.append("0"+cal.get(Calendar.DAY_OF_MONTH));
  else
    sb.append(cal.get(Calendar.DAY_OF_MONTH));
  if((cal.get(Calendar.MONTH)+1) < 10) 
    sb.append(".0"+(cal.get(Calendar.MONTH)+1)+"."+cal.get(Calendar.YEAR));
  else
    sb.append("."+(cal.get(Calendar.MONTH)+1)+"."+cal.get(Calendar.YEAR));
 // return(new String(cal.get(Calendar.HOUR_OF_DAY)+":"+cal.get(Calendar.MINUTE)+":"+cal.get(Calendar.SECOND)+" "+cal.get(Calendar.DAY_OF_MONTH)+"."+(cal.get(Calendar.MONTH)+1)+"."+cal.get(Calendar.YEAR)));
  return(sb.toString());
 }


 /**
   * timeString : Generates from a yyyymmddhhmmss string a hh:mm:ss dd.mm.yyy string.
   */
 String timeString(String str)
 {
  return(new String(str.substring(8,10)+":"+str.substring(10,12)+":"+str.substring(12,14)+" "+str.substring(6,8)+"."+str.substring(4,6)+"."+str.substring(0,4)));
 }


 /**
   * getUpdateString : Returns update time
   */
 String getUpdateString()
 {
  //Calendar cal=Calendar.getInstance(locale); 
  Calendar cal=Calendar.getInstance();
  StringBuffer sb=new StringBuffer();
  
  if(cal.get(Calendar.HOUR_OF_DAY) < 10)
    sb.append("0"+cal.get(Calendar.HOUR_OF_DAY));
  else
    sb.append(cal.get(Calendar.HOUR_OF_DAY));
  if(cal.get(Calendar.MINUTE) < 10)
    sb.append(":0"+cal.get(Calendar.MINUTE));
  else
    sb.append(":"+cal.get(Calendar.MINUTE));
  if(cal.get(Calendar.SECOND) < 10)
    sb.append(":0"+cal.get(Calendar.SECOND)+"<br>");
  else  
    sb.append(":"+cal.get(Calendar.SECOND)+"<br>");
  if(cal.get(Calendar.DAY_OF_MONTH) < 10) 
    sb.append("0"+cal.get(Calendar.DAY_OF_MONTH));
  else
    sb.append(cal.get(Calendar.DAY_OF_MONTH));
  if((cal.get(Calendar.MONTH)+1) < 10) 
    sb.append(".0"+(cal.get(Calendar.MONTH)+1)+"."+cal.get(Calendar.YEAR));
  else
    sb.append("."+(cal.get(Calendar.MONTH)+1)+"."+cal.get(Calendar.YEAR));
//  return(cal.get(Calendar.HOUR_OF_DAY)+":"+cal.get(Calendar.MINUTE)+":"+cal.get(Calendar.SECOND)+"<br>"+cal.get(Calendar.DAY_OF_MONTH)+"."+(cal.get(Calendar.MONTH)+1)+"."+cal.get(Calendar.YEAR));
  return(sb.toString());
 }

 /**
   * generateReports : Calls generateXXXXXXX functions according to the choice value. 
   */
 public void generateReports(ResourceBundle rb,Connection connection)
  throws SQLException
 {
  if(choice == 0 || choice > 31) {
   System.err.println(progName+":(generateReports): Wrong choice ("+choice+"). Allowed values are : 1-31");
   System.exit(1);
  }
  switch(choice) {
   case 1 :
           generateIndex(rb,connection);
           generateIndexOverview(rb,connection);
	   break;	
   case 2 :
           generateHostSSS(rb,connection);
           break;
   case 3 :
           generateIndex(rb,connection);
           generateIndexOverview(rb,connection);
           generateHostSSS(rb,connection);
           break;
   case 4 :
           generateHostServiceSHS(rb,connection);
           break;
   case 5 :
           generateIndex(rb,connection);
           generateIndexOverview(rb,connection);
           generateHostServiceSHS(rb,connection);
           break;
   case 6 :
           generateHostSSS(rb,connection);
           generateHostServiceSHS(rb,connection);
           break;
   case 7 :
           generateIndex(rb,connection);
           generateIndexOverview(rb,connection);
           generateHostSSS(rb,connection);
           generateHostServiceSHS(rb,connection);
           break;
   case 8 :
           generateServerInfo(rb,connection);
           break;
   case 11 :
           generateIndex(rb,connection);
           generateHostSSS(rb,connection);
           generateServerInfo(rb,connection);
           generateIndexOverview(rb,connection);
           break;
   case 31 :
           generateHostServiceSHSLinks(rb,connection);
           break;
   default :
           generateIndexOverview(rb,connection);
           generateIndex(rb,connection);
           generateServerInfo(rb,connection);
           generateHostSSS(rb,connection);
           generateHostServiceSHS(rb,connection);
           break;
  }
 }

 /**
   * generateIndexOverview : Generates an overview of the systems.
   */
 public void generateIndexOverview(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String language_str=rb.getString(progName+".language_name");
  String charset_str=rb.getString("Charset."+language_str);
  String dir_str=rb.getString(progName+".html_dir"); 
  int ncolumns=(new Integer(rb.getString(progName+".ncolumns"))).intValue();
 
  File htmlDir=new File(dir_str);
  if(!htmlDir.exists()) {
   System.err.println(progName+":(generateIndexOverviw): Directory "+htmlDir.toString()+" does not exist!");
   System.exit(1);
  }
  
  PrintWriter htmlFile=null;
  try {
   htmlFile=new PrintWriter(new FileWriter(new File(dir_str+"/index.html")));
  } 
  catch(IOException e) {
    System.err.println(progName+":(generateIndexOverview): "+htmlFile.toString()+" : "+e.getMessage());
    System.exit(1);
  }
		    
 //System.out.print(progName+":(generateIndex): Generating [System Status] ...");
  
  htmlFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
  htmlFile.println("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
  htmlFile.println("<meta NAME=\"GENERATOR\" CONTENT=\"SISIYAReport\">");
  htmlFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
  htmlFile.println("<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body bgcolor=\"#FFFFFF\">");
  htmlFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\">");
  htmlFile.println("<img src=\"images/company_logo.gif\" alt=\"Company's logo\">");
  htmlFile.println("</td><td align=\"center\"><h1>System Monitoring Tool</h1></td>");
  htmlFile.println("<td align=\"right\">Last updated<br>"+getUpdateString()+"<br></td></tr></table>");
  htmlFile.println("<center><a href=\"index_detailed.html\">Detailed View</a></center>");

  Statement stmt=conn.createStatement();
  ResultSet rset;

  // Get the overall status.
  // Only new MySQL supports nestet selects.
  // String sql_str="select str from status where id=(select max(statusid) from serverstatus);";
  String sql_str="select max(statusid) from serverstatus;";
  rset=stmt.executeQuery(sql_str);
  rset.next();
  sql_str="select str from status where id="+rset.getString(1)+";";
  rset=stmt.executeQuery(sql_str);
  rset.next();
  String global_status_str=rset.getString(1);
  
  
  sql_str="select c.hostname,b.str,a.str,d.str,e.str from serverstatus a,status b,servers c,servertypes d,locations e where a.statusid=b.id and a.serverid=c.id and c.servertypeid=d.id and c.locationid=e.id order by e.str,a.statusid desc,c.hostname;";
  rset=stmt.executeQuery(sql_str);

  htmlFile.println("<center><h2>System Status : <img src=\"images/"+global_status_str+"_big.gif\" alt=\"\">"+global_status_str+"</h2></center>");
  int serverCount=0;
  String old_location_str="";
  boolean flag=true; 
  while(flag ==  true) {
    //htmlFile.print("<tr>");
    for(int i=0;i<ncolumns && flag == true;i++) {
     if(! rset.next()) {
      flag=false;
      break;
     }
     if(old_location_str.equals(rset.getString(5)) == false) { // every time hen the location is changed
      if(old_location_str.equals("") == false) {  
        htmlFile.println("<tr><td colspan=\""+ncolumns+"\" bgcolor=\"#0000FF\"><font color=\"#FFFF00\">Total number of systems : "+serverCount+"</font></td></tr>");
       htmlFile.println("</table></center><br>");   
       serverCount=0;
      }
      htmlFile.println("<center><table border=1>");
      htmlFile.println("<tr><th colspan=\""+ncolumns+"\" bgcolor=\"#0000FF\"><font color=\"#FFFF00\">"+rset.getString(5)+"</font></th></tr>");
//      htmlFile.print("<tr>");
      old_location_str=rset.getString(5);
      i=0; // starting a new table
     }
     if(i == 0)
       htmlFile.print("<tr>");

     //htmlFile.print("<td><a href=\""+rset.getString(1)+"_sss.html\"><img src=\"images/"+rset.getString(2)+"_big.gif\"><br>"+rset.getString(1)+"</a></td>");
     htmlFile.print("<td><a href=\""+rset.getString(1)+"/sss.html\"><img border=\"0\" src=\"images/"+rset.getString(2)+"_big.gif\" alt=\""+rset.getString(2)+"\"></a></td>");
     serverCount++;
    }  
    htmlFile.print("</tr>");
  }
	     
//  htmlFile.print("</tr>");
  htmlFile.println("<tr><td colspan=\""+ncolumns+"\" bgcolor=\"#0000FF\"><font color=\"#FFFF00\">Total number of systems : "+serverCount+"</font></td></tr>");
  htmlFile.println("</table></center>");
  htmlFile.println("<br><center>Information about colors : <img src=\"images/Info.gif\" alt=\"Info.gif\">Info&nbsp;&nbsp;<img src=\"images/Ok.gif\" alt=\"Ok.gif\">Ok&nbsp;&nbsp;<img src=\"images/Warning.gif\" alt=\"Warning.gif\">Warning&nbsp;&nbsp;<img src=\"images/Error.gif\" alt=\"Error.gif\">Error</center>");
  htmlFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4></center>");
  htmlFile.println("</body></html>");
  
  htmlFile.close();
 }
 
 /**
   * generateIndex : Generates the index_detailed.html file.
   */
 public void generateIndex(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String language_str=rb.getString(progName+".language_name");
  String charset_str=rb.getString("Charset."+language_str);
  String dir_str=rb.getString(progName+".html_dir"); 
 
  File htmlDir=new File(dir_str);
  if(!htmlDir.exists()) {
   System.err.println(progName+":(generateIndex): Directory "+htmlDir.toString()+" does not exist!");
   System.exit(1);
  }
  
  PrintWriter htmlFile=null;
  try {
   htmlFile=new PrintWriter(new FileWriter(new File(dir_str+"/index_detailed.html")));
  } 
  catch(IOException e) {
    System.err.println(progName+":(generateIndex): "+htmlFile.toString()+" : "+e.getMessage());
    System.exit(1);
  }
		    
 //System.out.print(progName+":(generateIndex): Generating [System Status] ...");

 
  htmlFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
  htmlFile.println("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
  htmlFile.println("<meta NAME=\"GENERATOR\" CONTENT=\"SISIYAReport\">");
  htmlFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
  htmlFile.println("<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body bgcolor=\"#FFFFFF\">");
  htmlFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\">");
  htmlFile.println("<img src=\"images/company_logo.gif\" alt=\"Company's logo\">");
  htmlFile.println("</td><td align=\"center\"><h1>System Monitoring Tool</h1></td>");
  htmlFile.println("<td align=\"right\">Last updated<br>"+getUpdateString()+"<br></td></tr></table>");
  htmlFile.println("<center><a href=\"index.html\">Overview</a></center>");

  Statement stmt=conn.createStatement();
  ResultSet rset;

  // Get the overall status.
  // Only new MySQL supports nestet selects.
  // String sql_str="select str from status where id=(select max(statusid) from serverstatus);";
  String sql_str="select max(statusid) from serverstatus;";
  rset=stmt.executeQuery(sql_str);
  rset.next();
  sql_str="select str from status where id="+rset.getString(1)+";";
  rset=stmt.executeQuery(sql_str);
  rset.next();
  String global_status_str=rset.getString(1);
  
  
  sql_str="select c.hostname,b.str,a.str,a.updatetime,a.changetime,d.str,e.str from serverstatus a,status b,servers c,servertypes d,locations e where a.statusid=b.id and a.serverid=c.id and c.servertypeid=d.id and c.locationid=e.id order by e.str,a.statusid desc,c.hostname;";
  rset=stmt.executeQuery(sql_str);

  htmlFile.println("<center><h2>System Status : <img src=\"images/"+global_status_str+"_big.gif\" alt=\"\">"+global_status_str+"</h2></center>");
//  htmlFile.println("<center><table border=1>");
  //htmlFile.println("<tr><th>Server</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th></tr>");
 int serverCount=0;
  String old_location_str="";
  while(rset.next()) {
    if(old_location_str.equals(rset.getString(7)) == false) {
     if(old_location_str.equals("") == false) {
       htmlFile.println("<tr><td colspan=\"6\" bgcolor=\"#0000FF\"><font color=\"#FFFF00\">Total number of systems : "+serverCount+"</font></td></tr>");
       htmlFile.println("</table></center><br>");   
       serverCount=0;
     }
     htmlFile.println("<center><table border=1>");
     htmlFile.println("<tr><th colspan=\"6\" bgcolor=\"#0000FF\"><font color=\"#FFFF00\">"+rset.getString(7)+"</font></th></tr>");
     htmlFile.println("<tr><th>Server</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th><th>Changed in</th></tr>");
     old_location_str=rset.getString(7);
    }
    htmlFile.print("<tr><td><img src=\"images/"+rset.getString(6)+".gif\" alt=\""+rset.getString(6)+"\"><a href=\""+rset.getString(1)+"/sss.html\">"+rset.getString(1)+"</a></td><td align=\"center\"><img src=\"images/"+rset.getString(2)+"_big.gif\" alt=\""+rset.getString(2)+"\"></td><td>"+rset.getString(3)+"</td><td>"+timeString(rset.getTimestamp(4))+"</td><td>"+timeString(rset.getTimestamp(5))+"</td><td>"+getChangedString(rset.getTimestamp(4),rset.getTimestamp(5))+"</td></tr>");
    serverCount++;
  }
			    
	     
  htmlFile.println("<tr><td colspan=\"6\" bgcolor=\"#0000FF\"><font color=\"#FFFF00\">Total number of systems : "+serverCount+"</font></td></tr>");
  htmlFile.println("</table></center>");
  htmlFile.println("<br><center>Information about colors : <img src=\"images/Info.gif\" alt=\"Info.gif\">Info&nbsp;&nbsp;<img src=\"images/Ok.gif\" alt=\"Ok.gif\">Ok&nbsp;&nbsp;<img src=\"images/Warning.gif\" alt=\"Warning.gif\">Warning&nbsp;&nbsp;<img src=\"images/Error.gif\" alt=\"Error.gif\">Error</center>");
  htmlFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4></center>");
  htmlFile.println("</body></html>");
  
  htmlFile.close();
  
 //System.out.println("OK");
  
 }
  
 /**
   * generateSSS : Generates the Server Service Status (sss.html) file.
   */
 public void generateSSS(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String language_str=rb.getString(progName+".language_name");
  String charset_str=rb.getString("Charset."+language_str);
  String dir_str=rb.getString(progName+".html_dir"); 
 
  File htmlDir=new File(dir_str);
  if(!htmlDir.exists()) {
   System.err.println(progName+":(generateSSS): Directory "+htmlDir.toString()+" does not exist!");
   System.exit(1);
  }
  
  PrintWriter htmlFile=null;
  try {
   htmlFile=new PrintWriter(new FileWriter(new File(dir_str+"/sss.html")));
  } 
  catch(IOException e) {
    System.err.println(progName+":(generateSSS): "+htmlFile.toString()+" : "+e.getMessage());
    System.exit(1);
  }
		    
// System.out.print(progName+":(generateSSS): Generating [Server Service Status] ...");

 
  htmlFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
  htmlFile.println("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
  htmlFile.println("<meta NAME=\"GENERATOR\" CONTENT=\"SISIYAReport\">");
  htmlFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
  htmlFile.println("<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body bgcolor=\"#FFFFFF\">");
  htmlFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\">");
  htmlFile.println("<img src=\"images/company_logo.gif\" alt=\"Company's logo\">");
  htmlFile.println("</td><td align=\"center\"><h1>System Monitoring Tool</h1></td>");
  htmlFile.println("<td align=\"right\">Last updated<br>"+getUpdateString()+"<br></td></tr></table>");
  htmlFile.println("<center><a href=\"index.html\">System Status</a>&nbsp;&nbsp;</center>");

  String sql_str="select c.hostname,d.str,b.str,a.str,a.updatetime,a.changetime,d.id from serverservicestatus a,status b,servers c,services d where a.statusid=b.id and a.serverid=c.id and a.serviceid=d.id order by c.hostname,d.str;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);
  ResultSetMetaData rsmd=rset.getMetaData();	     
  htmlFile.println("<center><h1>System Service Status</h1></center>");
  htmlFile.println("<center><table border=1>");
  htmlFile.println("<tr><th>Server</th><th>Service</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th></tr>");
  while(rset.next()) {
    htmlFile.print("<tr><td><a href=\""+rset.getString(1)+"/sss.html\">"+rset.getString(1)+"</a></td><td><a href=\""+rset.getString(1)+"/service_"+rset.getString(7)+".html\">"+rset.getString(2)+"</a></td><td><img src=\"images/"+rset.getString(3)+".gif\">"+rset.getString(3)+"</td><td>"+rset.getString(4)+"</td><td>"+timeString(rset.getTimestamp(5))+"</td><td>"+timeString(rset.getTimestamp(6))+"</td></tr>");
  }
			    
	     
  htmlFile.println("</table></center>");
  htmlFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4><center>");
  htmlFile.println("<br><center>Information about colors : <img src=\"images/Info.gif\" alt=\"Info.gif\">Info&nbsp;&nbsp;<img src=\"images/Ok.gif\" alt=\"Ok.gif\">Ok&nbsp;&nbsp;<img src=\"images/Warning.gif\" alt=\"Warning.gif\">Warning&nbsp;&nbsp;<img src=\"images/Error.gif\" alt=\"Error.gif\">Error</center>");
  htmlFile.println("</body></html>");
  
  htmlFile.close();
  
// System.out.println("OK");
  
 }

 /**
   * generateSHS : Generates the Server History Status (shs.html) file.
   */
 public void generateSHS(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String language_str=rb.getString(progName+".language_name");
  String charset_str=rb.getString("Charset."+language_str);
  String dir_str=rb.getString(progName+".html_dir"); 
 
  File htmlDir=new File(dir_str);
  if(!htmlDir.exists()) {
   System.err.println(progName+":(generateSHS): Directory "+htmlDir.toString()+" does not exist!");
   System.exit(1);
  }
  
  PrintWriter htmlFile=null;
  try {
   htmlFile=new PrintWriter(new FileWriter(new File(dir_str+"/shs.html")));
  } 
  catch(IOException e) {
    System.err.println(progName+":(generateSHS): "+htmlFile.toString()+" : "+e.getMessage());
    System.exit(1);
  }
		    
 //System.out.print(progName+":(generateSHS): Generating [Server History Status] ...");

 
  htmlFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
  htmlFile.println("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
  htmlFile.println("<meta NAME=\"GENERATOR\" CONTENT=\"SISIYAReport\">");
  htmlFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
  htmlFile.println("<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body bgcolor=\"#FFFFFF\">");
  htmlFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\">");
  htmlFile.println("<img src=\"images/company_logo.gif\" alt=\"Company's logo\">");
  htmlFile.println("</td><td align=\"center\"><h1>System Monitoring Tool</h1></td>");
  htmlFile.println("<td align=\"right\">Last updated<br>"+getUpdateString()+"<br></td></tr></table>");
  htmlFile.println("<center><a href=\"index.html\">System Status</a>&nbsp;&nbsp;</center>");

  String sql_str="select a.sendtime as SendTime,c.hostname as Server,d.str as Service,b.str as Status,a.str as Description,a.recievetime as RecieveTime,d.id from serverhistorystatus a,status b,servers c,services d where a.statusid=b.id and a.serverid=c.id and a.serviceid=d.id order by a.sendtime desc;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);
  ResultSetMetaData rsmd=rset.getMetaData();	     
  htmlFile.println("<center><h1>System History Status</h1></center>");
  htmlFile.println("<center><table border=1>");
  htmlFile.println("<tr><th>Send Time</th><th>Server</th><th>Service</th><th>Status</th><th>Description</th><th>Recieve Time</th></tr>");
  while(rset.next()) {
    htmlFile.print("<tr><td>"+timeString(rset.getTimestamp(1))+"</td><td><a href=\""+rset.getString(2)+"/sss.html\">"+rset.getString(2)+"</a></td><td><a href=\""+rset.getString(2)+"/service_"+rset.getString(7)+".html\">"+rset.getString(3)+"</a></td><td><img src=\"images/"+rset.getString(4)+".gif\">"+rset.getString(4)+"</td><td>"+rset.getString(5)+"</td><td>"+timeString(rset.getTimestamp(6))+"</td></tr>");
  }
			    
	     
  htmlFile.println("</table></center>");
  htmlFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4><center>");
  htmlFile.println("<br><center>Information about colors : <img src=\"images/Info.gif\" alt=\"Info.gif\">Info&nbsp;&nbsp;<img src=\"images/Ok.gif\" alt=\"Ok.gif\">Ok&nbsp;&nbsp;<img src=\"images/Warning.gif\" alt=\"Warning.gif\">Warning&nbsp;&nbsp;<img src=\"images/Error.gif\" alt=\"Error.gif\">Error</center>");
  htmlFile.println("</body></html>");
  htmlFile.close();
 }

 /**
   * generateHostSSS : Generates the Server Service Status for every host (host_sss.html files.
   */
 public void generateHostSSS(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String language_str=rb.getString(progName+".language_name");
  String charset_str=rb.getString("Charset."+language_str);
  String dir_str=rb.getString(progName+".html_dir"); 
 
  File htmlDir=new File(dir_str);
  if(!htmlDir.exists()) {
   System.err.println(progName+":(generateHostSSS): Directory "+htmlDir.toString()+" does not exist!");
   System.exit(1);
  }
  
  String sql_str="select c.hostname,d.str,b.str,a.str,a.updatetime,a.changetime,d.id from serverservicestatus a,status b,servers c,services d where a.statusid=b.id and a.serverid=c.id and a.serviceid=d.id order by c.id,a.statusid desc,d.str;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);
  ResultSetMetaData rsmd=rset.getMetaData();	     
  PrintWriter htmlFile=null;
  String old_server="";
  while(rset.next()) {
   if(old_server.equals(rset.getString(1)) == false) {
     if(old_server.equals("") == false) {
        htmlFile.println("</table></center>");
        htmlFile.println("<br><center>Information about colors : <img src=\"../images/Info.gif\" alt=\"Info.gif\">Info&nbsp;&nbsp;<img src=\"../images/Ok.gif\" alt=\"Ok.gif\">Ok&nbsp;&nbsp;<img src=\"../images/Warning.gif\" alt=\"Warning.gif\">Warning&nbsp;&nbsp;<img src=\"../images/Error.gif\" alt=\"Error.gif\">Error</center>");
        htmlFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4></center>");
	htmlFile.println("</body></html>");
        htmlFile.close();
     }
     old_server=rset.getString(1);
 
     File dir=new File(htmlDir.toString()+File.separatorChar+rset.getString(1));
     if(!dir.exists()) {
       try {
         dir.mkdir();
       }
       catch(SecurityException e) {
         System.err.println(progName+":(generateHostSSS): Cannot create directory "+dir.toString()+" : "+e.getMessage());
         System.exit(1);
       }
     }


     try {
 
         htmlFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(1)+"/sss.html")));
     } 
     catch(IOException e) {
      System.err.println(progName+":(generateHostSSS): "+htmlFile.toString()+" : "+e.getMessage());
      System.exit(1);
     }
     htmlFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
     htmlFile.println("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
     htmlFile.println("<meta NAME=\"GENERATOR\" CONTENT=\"SISIYAReport\">");
     htmlFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
     htmlFile.println("<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body bgcolor=\"#FFFFFF\">");
     htmlFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\">");
     htmlFile.println("<img src=\"../images/company_logo.gif\" alt=\"Company's logo\">");
     htmlFile.println("</td><td align=\"center\"><h1>System Monitoring Tool</h1></td>");
     htmlFile.println("<td align=\"right\">Last updated<br>"+getUpdateString()+"<br></td></tr></table>");
     htmlFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\" rowspan=\"2\">");
     htmlFile.println("<img src=\"../images/"+rset.getString(1)+".gif\" alt=\""+rset.getString(1)+"\"></td>");
     htmlFile.println("<td><a href=\"../index.html\">System Status</a></td><td><a href=\"info.html\">System Info</a>");
     htmlFile.println("<tr><td>System : "+rset.getString(1)+"</td></tr></table>");
     htmlFile.println("<center><table border=1>");
     htmlFile.println("<tr><th>Service</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th><th>Changed in</th></tr>"); 
   } 
   // content
   htmlFile.println("<tr><td><a href=\"service_"+rset.getString(7)+"_index.html\">"+rset.getString(2)+"</a></td><td align=\"center\"><img src=\"../images/"+rset.getString(3)+".gif\" alt=\""+rset.getString(3)+"\"></td><td>"+rset.getString(4)+"</td><td>"+timeString(rset.getTimestamp(5))+"</td><td>"+timeString(rset.getTimestamp(6))+"</td><td>"+getChangedString(rset.getTimestamp(5),rset.getTimestamp(6))+"</td></tr>"); 	
    //timeString(rset.getTimestamp(5));
  }
  if(htmlFile != null) htmlFile.close();
 }

 /**
   * generateHostServisSHSLinks : Generates the Server History Status for every host and service (host_service_sid.html files from
   * serverhistorystatusall table. And populate serversdates table.
   */
 public void generateHostServiceSHSLinks(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String sql_str="select a.id,b.serviceid,a.hostname from servers a,serverservice b where a.id=b.serverid and a.active=b.active and a.active=1 order by a.id,b.serviceid;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);

  while(rset.next()) {
   java.sql.Timestamp startTimestamp=getStartTimestamp(conn,rset.getInt(1),rset.getInt(2));

   if(startTimestamp == null)
    System.err.println("No record for ("+rset.getInt(1)+","+rset.getInt(2)+")");
   else {
    System.out.println("Start time for "+rset.getString(3)+"("+rset.getInt(1)+","+rset.getInt(2)+"):"+startTimestamp);
    generateHostServiceSHSLinksFile(rb,conn,rset.getInt(1),rset.getString(3),rset.getInt(2),startTimestamp);
   }
  }
 }
 
 /**
   */
 private void generateHostServiceSHSLinksFile(ResourceBundle rb,Connection conn,int systemid,String systemName,int serviceid,java.sql.Timestamp startTimestamp)
  throws SQLException
 {
  Calendar cal=Calendar.getInstance();
  java.util.Date today=cal.getTime(); 
  java.util.Date startDate=startTimestamp; 
//  System.out.println("Today      :"+today.toString());
//  System.out.println("Start date :"+startDate.toString());
  PrintWriter htmlLinksFile=null;
  String dir_str=rb.getString(progName+".html_dir");
  File dir=new File(dir_str+File.separatorChar+systemName);
  if(!dir.exists()) {
     try { dir.mkdir(); }
     catch(SecurityException e) {
         System.err.println(progName+":(generateHostServiceSHSLinksFile): Cannot create directory "+dir.toString()+" : "+e.getMessage());
         System.exit(1);
     }
  }
  try {
    htmlLinksFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+systemName+File.separatorChar+"service_"+serviceid+"_links.html")));
  } 
  catch(IOException e) {
      System.err.println(progName+":(generateHostServiceSHSLinksFile): "+htmlLinksFile.toString()+" : "+e.getMessage());
      System.exit(1);
  }

  htmlLinksFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional //EN\" \"http://www.w3.org/TR/html4/loose.dtd\"><html>");
  htmlLinksFile.println("<head><title>System Monitoring Tool (by Erdal Mutlu)</title><base target=\"contents\">");
  htmlLinksFile.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\"></head><body bgcolor=\"#FFFFFF\">"); 
  //cal.setTime(startDate); 
  cal.setTime(today); 
  File f;
  String currentDateString;
  //for(java.util.Date d=startDate;d.compareTo(today) <= 0;cal.add(Calendar.DATE,1),d=cal.getTime()) {
  for(java.util.Date d=today;d.compareTo(startDate) >= 0;cal.add(Calendar.DATE,-1),d=cal.getTime()) {
    currentDateString=getDateString(d);
    System.out.print("Generating for "+systemName+"("+systemid+","+serviceid+") "+currentDateString+"...");

    f=new File(dir_str+File.separatorChar+systemName+File.separatorChar+currentDateString+"_service_"+serviceid+"_contents.html");
    if(f.exists()) {
      if(f.length() == 0)
        f.delete();
      else
        htmlLinksFile.println("<a href=\""+currentDateString+"_service_"+serviceid+"_contents.html\">"+currentDateString.substring(6,8)+"."+currentDateString.substring(4,6)+"."+currentDateString.substring(0,4)+"</a><br>"); 
      System.out.println("Skipping");
      continue;
    }
    generateHostServiceSHS(rb,conn,systemid,systemName,serviceid,d);
    if(f.length() == 0) {
       f.delete();
       System.out.println(" Ziro sized file. removed");
    }
    else
       System.out.println("OK");
  } 
  htmlLinksFile.println("</body></html>"); 
  htmlLinksFile.close();
 }

 /**
   * generateHostServisSHS : Generates the Server History Status for every host.
   */
 public void generateHostServiceSHS(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  generateHostServiceSHS(rb,conn,-1,null,-1,null);
 }

 /**
   * generateHostServisSHS : Generates the Server History Status for every host and service (host_service_sid.html files.
   */
 public void generateHostServiceSHS(ResourceBundle rb,Connection conn,int systemid,String systemName,int serviceid,java.util.Date d)
  throws SQLException
 {
  Statement stmt;
  ResultSet rset;
  String sql_str;

  String language_str=rb.getString(progName+".language_name");
  String charset_str=rb.getString("Charset."+language_str);
  String dir_str=rb.getString(progName+".html_dir"); 
  String currentDateString;

  if(systemName == null) {
    sql_str="select a.sendtime,c.hostname,d.str,b.str,a.str,a.recievetime,d.id from serverhistorystatus a,status b,servers c,services d where a.statusid=b.id and a.serverid=c.id and a.serviceid=d.id order by a.serverid,d.id,a.sendtime desc;";
    stmt=conn.createStatement();
    rset=stmt.executeQuery(sql_str);
  }
  else {
    currentDateString=getDateString(d);
    sql_str="select a.sendtime,c.hostname,d.str,b.str,a.str,a.recievetime,d.id from serverhistorystatusall a,status b,servers c,services d where a.serverid="+systemid+" and a.serviceid="+serviceid+" and a.statusid=b.id and a.serverid=c.id and a.serviceid=d.id and a.sendtime like '"+currentDateString+"%' order by a.sendtime desc;";
    stmt=conn.createStatement();
    rset=stmt.executeQuery(sql_str);
 
    if(rset.next() == false) {
      sql_str="select a.sendtime,c.hostname,d.str,b.str,a.str,a.recievetime,d.id from serverhistorystatus a,status b,servers c,services d where a.serverid="+systemid+" and a.serviceid="+serviceid+" and a.statusid=b.id and a.serverid=c.id and a.serviceid=d.id and a.sendtime like '"+currentDateString+"%' order by a.sendtime desc;";
      rset=stmt.executeQuery(sql_str);
    }
    else
     rset.beforeFirst();
  }

// System.out.print(progName+":(generateHostServiceSHS): Generating [Server History Status for every host and service] ...");

  PrintWriter htmlUpFile=null,htmlIndexFile=null,htmlContentsFile=null;
  String old_server="",old_sid="";
  while(rset.next()) {
   if(old_server.equals(rset.getString(2)) == false || old_sid.equals(rset.getString(7)) == false) {
     if(old_server.equals("") == false) {
        htmlContentsFile.println("</table></center>");
        htmlContentsFile.println("<br><center>Information about colors : <img src=\"../images/Info.gif\" alt=\"Info.gif\">Info&nbsp;&nbsp;<img src=\"../images/Ok.gif\" alt=\"Ok.gif\">Ok&nbsp;&nbsp;<img src=\"../images/Warning.gif\" alt=\"Warning.gif\">Warning&nbsp;&nbsp;<img src=\"../images/Error.gif\" alt=\"Error.gif\">Error</center>");
        htmlContentsFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4></center>");
	htmlContentsFile.println("</body></html>");
        htmlContentsFile.close();
     }
     if(old_server.equals(rset.getString(2)) == false) {
       old_server=rset.getString(2);
       old_sid=rset.getString(7);
     }
     if(old_sid.equals(rset.getString(7)) == false) {
       old_sid=rset.getString(7);
     }
  
     // The test about existence of this directory is done in generateHostServiceSHSLinksFile
     File dir=new File(dir_str+File.separatorChar+rset.getString(2));
     currentDateString=getDateString(rset.getTimestamp(1));

     try {
      htmlIndexFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(2)+File.separatorChar+"service_"+rset.getString(7)+"_index.html")));
      htmlUpFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(2)+File.separatorChar+"service_"+rset.getString(7)+"_up.html")));
      htmlContentsFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(2)+File.separatorChar+currentDateString+"_service_"+rset.getString(7)+"_contents.html")));
     } 
     catch(IOException e) {
      System.err.println(progName+":(generateHostServiceSHS): "+htmlIndexFile.toString()+","+htmlUpFile.toString()+","+htmlContentsFile.toString()+" : "+e.getMessage());
      System.exit(1);
     }
     htmlIndexFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\"><html>");
     htmlIndexFile.println("<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
     htmlIndexFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
     htmlIndexFile.println("<title>SISIYA</title></head>");
     htmlIndexFile.println("<frameset rows=\"20%,80%\">");
     htmlIndexFile.println("<frame name=\"up\"  src=\"service_"+rset.getString(7)+"_up.html\" scrolling=\"auto\">");
     htmlIndexFile.println("<frameset cols=\"%10,%90\">");
     htmlIndexFile.println("<frame name=\"links\" src=\"service_"+rset.getString(7)+"_links.html\" scrolling=\"auto\">");
     htmlIndexFile.println("<frame name=\"contents\" src=\""+currentDateString+"_service_"+rset.getString(7)+"_contents.html\" scrolling=\"auto\">");
     htmlIndexFile.println("</frameset><noframes><body bgcolor=\"#FFFFFF\"><table border=\"1\">");
     htmlIndexFile.println("<tr><td><a href=\"service_"+rset.getString(7)+"_up.html\">Upper part</a></td></tr>");
     htmlIndexFile.println("<tr><td><a href=\"service_"+rset.getString(7)+"_links.html\">Links</a></td></tr>");
     htmlIndexFile.println("<tr><td><a href=\""+currentDateString+"_service_"+rset.getString(7)+"_contents.html\">Contents</a></td></tr>");
     htmlIndexFile.println("</table></body></noframes></frameset></html>");
     htmlIndexFile.close(); 
     htmlUpFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional //EN\" \"http://www.w3.org/TR/html4/loose.dtd\"><html>");
     htmlUpFile.println("<head><title>System Monitoring Tool (by Erdal Mutlu)</title>");
     htmlUpFile.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
     htmlUpFile.println("<meta NAME=\"GENERATOR\" CONTENT=\"SISIYAReport\">");
     htmlUpFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\"></head><body bgcolor=\"#FFFFFF\">");
     htmlUpFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\">");
     htmlUpFile.println("<img src=\"../images/company_logo.gif\" alt=\"Company's logo\">");
     htmlUpFile.println("</td><td align=\"center\"><h1>System Monitoring Tool</h1></td>");
     htmlUpFile.println("<td align=\"right\">Last updated<br>"+getUpdateString()+"<br></td></tr></table>");
     htmlUpFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\" rowspan=\"2\">");
     htmlUpFile.println("<img src=\"../images/"+rset.getString(2)+".gif\" alt=\""+rset.getString(2)+"\"></td>");
     htmlUpFile.println("<td><a href=\"../index.html\" target=\"_top\">System Status</a></td><td>");
     // check for server image
     htmlUpFile.println("<a href=\"sss.html\" target=\"_top\">Server Service Status for ["+rset.getString(2)+"]</a></td><td><a href=\"info.html\" target=\"_top\">System Info</a>");
     htmlUpFile.println("</td></tr><tr><td>System : "+rset.getString(2)+"</td><td>Service : "+rset.getString(3));
     htmlUpFile.println("</td></tr></table></html>");
     htmlUpFile.close();
     htmlContentsFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional //EN\" \"http://www.w3.org/TR/html4/loose.dtd\"><html>");
     htmlContentsFile.println("<head><title>System Monitoring Tool (by Erdal Mutlu)</title>");
     htmlContentsFile.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
     htmlContentsFile.println("</head><body bgcolor=\"#FFFFFF\"><center><table border=1>");
     htmlContentsFile.println("<tr><th>Send Time</th><th>Status</th><th>Description</th><th>Recieve Time</th></tr>"); 
   } 
   // content
   htmlContentsFile.println("<tr><td>"+timeString(rset.getTimestamp(1))+"</td><td align=\"center\"><img src=\"../images/"+rset.getString(4)+".gif\" alt=\""+rset.getString(4)+"\"></td><td>"+rset.getString(5)+"</td><td>"+timeString(rset.getTimestamp(6))+"</td></tr>"); 	
  }
  if(htmlContentsFile != null) {
    htmlContentsFile.println("</table></center>");
    htmlContentsFile.println("<br><center>Information about colors : <img src=\"../images/Info.gif\" alt=\"Info.gif\">Info&nbsp;&nbsp;<img src=\"../images/Ok.gif\" alt=\"Ok.gif\">Ok&nbsp;&nbsp;<img src=\"../images/Warning.gif\" alt=\"Warning.gif\">Warning&nbsp;&nbsp;<img src=\"../images/Error.gif\" alt=\"Error.gif\">Error</center>");
    htmlContentsFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4></center>");
    htmlContentsFile.println("</body></html>");
    htmlContentsFile.close();
  }
 }

 /**
   * generateHostServisSHS : Generates the Server History Status for the given host,servicve and date.
   */
 public void generateHostServiceSHSold(ResourceBundle rb,Connection conn,int systemid,String systemName,int serviceid,java.util.Date d)
  throws SQLException
 {
  String language_str=rb.getString(progName+".language_name");
  String charset_str=rb.getString("Charset."+language_str);
  String dir_str=rb.getString(progName+".html_dir"); 

  String currentDateString=getDateString(d);
 
  String sql_str="select a.sendtime,c.hostname,d.str,b.str,a.str,a.recievetime,d.id from serverhistorystatusall a,status b,servers c,services d where a.serverid="+systemid+" and a.serviceid="+serviceid+" and a.statusid=b.id and a.serverid=c.id and a.serviceid=d.id and a.sendtime like '"+currentDateString+"%' order by a.sendtime desc;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);
 
  if(rset.next() == false) {
    sql_str="select a.sendtime,c.hostname,d.str,b.str,a.str,a.recievetime,d.id from serverhistorystatus a,status b,servers c,services d where a.serverid="+systemid+" and a.serviceid="+serviceid+" and a.statusid=b.id and a.serverid=c.id and a.serviceid=d.id and a.sendtime like '"+currentDateString+"%' order by a.sendtime desc;";
    rset=stmt.executeQuery(sql_str);
  }
  else
   rset.beforeFirst();

 
  PrintWriter htmlUpFile=null,htmlIndexFile=null,htmlContentsFile=null,htmlLinksFile=null;
  if(rset.next() == false)
    return;
  else {
     File dir=new File(dir_str+File.separatorChar+rset.getString(2));
     // The test about existence of this directory is done in generateHostServiceSHSLinksFile
     try {
      htmlIndexFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(2)+File.separatorChar+"service_"+rset.getString(7)+"_index.html")));
      htmlUpFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(2)+File.separatorChar+"service_"+rset.getString(7)+"_up.html")));
      htmlLinksFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(2)+File.separatorChar+"service_"+rset.getString(7)+"_links.html")));
      htmlContentsFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(2)+File.separatorChar+currentDateString+"_service_"+rset.getString(7)+"_contents.html")));
     } 
     catch(IOException e) {
      System.err.println(progName+":(generateHostServiceSHS): "+htmlIndexFile.toString()+","+htmlUpFile.toString()+","+htmlLinksFile.toString()+","+htmlContentsFile.toString()+" : "+e.getMessage());
      System.exit(1);
     }

     htmlIndexFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\"><html>");
     htmlIndexFile.println("<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
     htmlIndexFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
     htmlIndexFile.println("<title>SISIYA</title></head>");
     htmlIndexFile.println("<frameset rows=\"20%,80%\">");
     htmlIndexFile.println("<frame name=\"up\"  src=\"service_"+rset.getString(7)+"_up.html\" scrolling=\"auto\">");
     htmlIndexFile.println("<frameset cols=\"%10,%90\">");
     htmlIndexFile.println("<frame name=\"links\" src=\"service_"+rset.getString(7)+"_links.html\" scrolling=\"auto\">");
     htmlIndexFile.println("<frame name=\"contents\" src=\""+currentDateString+"_service_"+rset.getString(7)+"_contents.html\" scrolling=\"auto\">");
     htmlIndexFile.println("</frameset><noframes><body bgcolor=\"#FFFFFF\"><table border=\"1\">");
     htmlIndexFile.println("<tr><td><a href=\"service_"+rset.getString(7)+"_up.html\">Upper part</a></td></tr>");
     htmlIndexFile.println("<tr><td><a href=\"service_"+rset.getString(7)+"_links.html\">Links</a></td></tr>");
     htmlIndexFile.println("<tr><td><a href=\""+currentDateString+"_service_"+rset.getString(7)+"_contents.html\">Contents</a></td></tr>");
     htmlIndexFile.println("</table></body></noframes></frameset></html>");
     htmlIndexFile.close(); 
     htmlUpFile.println("<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
     htmlUpFile.println("<meta NAME=\"GENERATOR\" CONTENT=\"SISIYAReport\">");
     htmlUpFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
     htmlUpFile.println("<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body bgcolor=\"#FFFFFF\">");
     htmlUpFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\">");
     htmlUpFile.println("<img src=\"../images/company_logo.gif\" alt=\"Company's logo\">");
     htmlUpFile.println("</td><td align=\"center\"><h1>System Monitoring Tool</h1></td>");
     htmlUpFile.println("<td align=\"right\">Last updated<br>"+getUpdateString()+"<br></td></tr></table>");
     htmlUpFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\" rowspan=\"2\">");
     htmlUpFile.println("<img src=\"../images/"+rset.getString(2)+".gif\"></td>");
     htmlUpFile.println("<td><a href=\"../index.html\" target=\"_top\">System Status</a></td><td>");
     // check for server image
     htmlUpFile.println("<a href=\"sss.html\" target=\"_top\">Server Service Status for ["+rset.getString(2)+"]</a></td><td><a href=\"info.html\" target=\"_top\">System Info</a>");
     htmlUpFile.println("</td></tr><tr><td>System : "+rset.getString(2)+"</td><td>Service : "+rset.getString(3));
     htmlUpFile.println("</td></tr></table>");
     htmlUpFile.close();
     htmlContentsFile.println("<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\"></head>");
     htmlContentsFile.println("<center><table border=1>");
     htmlContentsFile.println("<tr><th>Send Time</th><th>Status</th><th>Description</th><th>Recieve Time</th></tr>"); 
    rset.beforeFirst();
  }

  while(rset.next()) {
   // content
   htmlContentsFile.println("<tr><td>"+timeString(rset.getTimestamp(1))+"</td><td><img src=\"../images/"+rset.getString(4)+".gif\">"+rset.getString(4)+"</td><td>"+rset.getString(5)+"</td><td>"+timeString(rset.getTimestamp(6))+"</td></tr>"); 	
  }

  htmlContentsFile.println("</table></center>");
  htmlContentsFile.println("<br><center>Information about colors : <img src=\"images/Info.gif\" alt=\"Info.gif\">Info&nbsp;&nbsp;<img src=\"images/Ok.gif\" alt=\"Ok.gif\">Ok&nbsp;&nbsp;<img src=\"images/Warning.gif\" alt=\"Warning.gif\">Warning&nbsp;&nbsp;<img src=\"images/Error.gif\" alt=\"Error.gif\">Error</center>");
  htmlContentsFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4></center>");
  htmlContentsFile.println("</body></html>");
  htmlContentsFile.close();
 }

 /**
   * getStartTimestamp: Finds the first date for this server-service from serverhistorystatusall or serverhistorystatus.
   */
 private java.sql.Timestamp getStartTimestamp(Connection conn,int systemid,int serviceid)
  throws SQLException
 {
  String sql_str="select starttime from serverservice where serverid="+systemid+" and serviceid="+serviceid+" and active=1;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);

  if(rset.next()) 
   return(rset.getTimestamp(1));
  else 
    return(null); // there is no record for this (systemid,serviceid)
 }


 /**
   * generateServerInfo : Generates info about the systems.
   */
 public void generateServerInfo(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String language_str=rb.getString(progName+".language_name");
  String charset_str=rb.getString("Charset."+language_str);
  String dir_str=rb.getString(progName+".html_dir"); 
 
  File htmlDir=new File(dir_str);
  if(!htmlDir.exists()) {
   System.err.println(progName+":(generateServerInfo): Directory "+htmlDir.toString()+" does not exist!");
   System.exit(1);
  }
  
  	    
  String sql_str="select a.hostname,a.fullhostname,a.cpu,a.ram,a.hd,a.vendorstr,a.sizestr from servers a,servertypes b,locations c where a.servertypeid=b.id and a.locationid=c.id;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);
  ResultSetMetaData rsmd=rset.getMetaData();	     

  PrintWriter htmlFile=null;
  String old_server="";
  while(rset.next()) {
   if(old_server.equals(rset.getString(1)) == false) {
     if(old_server.equals("") == false) {
        htmlFile.println("</table></center>");
   //     htmlFile.println("<br><center>Information about colors : <img src=\"../images/Info.gif\">Info&nbsp;&nbsp;<img src=\"../images/Ok.gif\">Ok&nbsp;&nbsp;<img src=\"../images/Warning.gif\">Warning&nbsp;&nbsp;<img src=\"../images/Error.gif\">Error</center>");
        htmlFile.println("<br><center><h4>System Monitoring Tool (SISIYA) &copy; Erdal Mutlu</h4></center>");
	htmlFile.println("</body></html>");
        htmlFile.close();
     }
     old_server=rset.getString(1);
  
     File dir=new File(htmlDir.toString()+File.separatorChar+rset.getString(1));
     if(!dir.exists()) {
       try {
         dir.mkdir();
       }
       catch(SecurityException e) {
         System.err.println(progName+":(generateServerInfo): Cannot create directory "+dir.toString()+" : "+e.getMessage());
         System.exit(1);
       }
     }
     try {
      htmlFile=new PrintWriter(new FileWriter(new File(dir_str+File.separatorChar+rset.getString(1)+File.separatorChar+"info.html")));
     } 
     catch(IOException e) {
      System.err.println(progName+":(generateServerInfo): "+htmlFile.toString()+" : "+e.getMessage());
      System.exit(1);
     }
     htmlFile.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
     htmlFile.println("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset="+charset_str+"\">");
     htmlFile.println("<meta NAME=\"GENERATOR\" CONTENT=\"SISIYAReport\">");
     htmlFile.println("<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">");
     htmlFile.println("<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body bgcolor=\"#FFFFFF\">");
     htmlFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\">");
     htmlFile.println("<img src=\"../images/company_logo.gif\" alt=\"Company's logo\">");
     htmlFile.println("</td><td align=\"center\"><h1>System Monitoring Tool</h1></td>");
     htmlFile.println("<td align=\"right\">Last updated<br>"+getUpdateString()+"<br></td></tr></table>");
     htmlFile.println("<table border=\"0\" width=\"100%\"><tr><td align=\"left\" rowspan=\"2\">");
     htmlFile.println("<img src=\"../images/"+rset.getString(1)+".gif\"></td>");
     htmlFile.println("<td align=\"center\"><a href=\"../index.html\">System Status</a></td></tr><tr><td align=\"center\">");
     // check for server image
     //htmlFile.println("<center><img src=\"../images/"+rset.getString(1)+".gif\"><a href=\""+rset.getString(1)+"_sss.html\">Server Service Status for ["+rset.getString(1)+"]</a>&nbsp;&nbsp;<a href=\""+rset.getString(1)+"_shs.html\">System Status History for ["+rset.getString(1)+"]</a></center><br>");
     htmlFile.println("<a href=\"sss.html\">Server Service Status for ["+rset.getString(1)+"]</a>");
     htmlFile.println("</td></tr></table>");
     htmlFile.println("<center><table border=1>");
     htmlFile.println("<tr><th>Hostname</th><th>Full Hostname</th><th>CPU</th><th>RAM</th><th>HD</th><th>Vendor Info</th><th>Size</th></tr>"); 
   } 
   // content
   htmlFile.println("<tr><td>"+rset.getString(1)+"</td><td>"+rset.getString(2)+"</td><td>"+rset.getString(3)+"</td><td>"+rset.getString(4)+"</td><td>"+rset.getString(5)+"</td><td>"+rset.getString(6)+"</td><td>"+rset.getString(7)+"</td></tr>"); 	
  }
  if(htmlFile != null) htmlFile.close();
 }

}	  
