import java.sql.*;
import java.io.*;
//import java.text.*;
import java.util.*;
import java.net.*;
 
/**
  * SISIYAUtils. Some utility functions for the SISIYA Database.
  * @version 0.1 20.12.2003
  * @author Erdal MUTLU
  */ 
public class SISIYAUtils 
{
 final static String progName="SISIYAUtils";
 final static String rbName="SISIYA";
 String dateString; // yesterday as a yyyymmdd string
 int choice=0; // 2^0=serverstatus, 2^1=serverservericestatus, 2^3=serverhistorystatus 2^4=serverhistorystatusall

 /**
   * Default contsructor.
   */
 SISIYAUtils()
 {
  getDateString();
 }

 public static void main(String args[])
  throws SQLException
 {

  if(args.length != 2) {
     System.err.println("Usage   : "+progName+" locale choice");
     System.err.println("Example : "+progName+" en 1");
     System.err.println("1=Update systemservice table");
     System.err.println("2=Fill empty days, so that history generation does not take too long for execution");
     System.exit(1);
  }
  SISIYAUtils sisiyautils=new SISIYAUtils();

  
  ResourceBundle rb=null;
  String locale_str="null";
  String jdbc_driver_str=null;
  String jdbc_url_str=null;
  String user_str=null;
  String password_str=null;
  String charset_str=null;
  Connection connection=null; 


  locale_str=new String(args[0]);
  sisiyautils.choice=(new Integer(args[1])).intValue();

  Locale locale=new Locale(locale_str,locale_str.toUpperCase());
  rb=ResourceBundle.getBundle(rbName,locale);
  
  jdbc_driver_str=rb.getString(rbName+".jdbc_driver");
  jdbc_url_str=rb.getString(rbName+".jdbc_url");
  user_str=rb.getString(rbName+".user");
  password_str=rb.getString(rbName+".password");
 
  PrintWriter out=new PrintWriter(System.out,true);

  boolean errorFlag=false; 
  try {
      connection=sisiyautils.loginToDB(out,jdbc_driver_str,jdbc_url_str,user_str,password_str); 
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
  sisiyautils.utils(rb,connection);
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
   * utils: Executes varios utils.
   */
 public void utils(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  switch(choice) {
   case 1  :
             updateServerService(rb,conn);
	     break;	
   case 2  : fillEmptyDays(rb,conn);
             break;
   default :
           updateServerService(rb,conn);
           break;
  }
 }

 /*
    getDateString : Generates from a Timestamp a yyyymmdd string.
   

  void getDateString()
 { 
  Calendar cal=Calendar.getInstance();
  StringBuffer sb=new StringBuffer((new Integer(cal.get(Calendar.YEAR))).toString());
  if((cal.get(Calendar.MONTH)+1) < 10) 
    sb.append("0"+(cal.get(Calendar.MONTH)+1));
  else
    sb.append((cal.get(Calendar.MONTH)+1));
  if(cal.get(Calendar.DAY_OF_MONTH) < 10) 
    sb.append("0"+cal.get(Calendar.DAY_OF_MONTH));
  else
    sb.append(cal.get(Calendar.DAY_OF_MONTH));

  dateString=sb.toString();
 }
*/

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
   *  updateServerService: Updates the systemservice table. 
   */
 private void updateServerService(ResourceBundle rb,Connection conn)
  throws SQLException
 {
//  System.out.println(progName+"( updateServerService): executing ...");
  String sql_str="select a.id,b.serviceid from servers a,systemservicestatus b where a.id=b.serverid and a.active=1 order by a.id,b.serviceid;";
  //String sql_str="select a.id,b.serviceid from servers a,systemservicestatus b where a.id=b.serverid and a.active=1 and serverid=12 order by a.id,b.serviceid;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);
  Statement stmt2=conn.createStatement();
  ResultSet rset2;
  PreparedStatement pstmt=conn.prepareStatement("insert into systemservice values(?,?,?,?)");
  while(rset.next()) {
//   System.out.println("ServerID="+rset.getInt(1)+" ServiceID="+rset.getInt(2)+" is updated in systemservice table.");      
   pstmt.setInt(1,rset.getInt(1));
   pstmt.setInt(2,rset.getInt(2));
   pstmt.setBoolean(3,true);
   pstmt.setTimestamp(4,getFirstTimestamp(conn,rset.getInt(1),rset.getInt(2)));
   rset2=stmt2.executeQuery("select * from systemservice where serverid="+rset.getInt(1)+" and serviceid="+rset.getInt(2));
   if(!rset2.next()) {
     //   System.out.println("Executing :"+pstmt.toString()+")");
     try { pstmt.execute(); }
     catch(SQLException e) { System.err.println(progName+":(updateServerService):"+e.getMessage()); }
   }
   else
    System.out.println(progName+":(updateServerService): There is already a record for serverid="+rset.getInt(1)+" and serviceid="+rset.getInt(2));
  }
//  System.out.println(progName+"( updateServerService): executing ...OK");
 }


 /**
   *  updateServerService: Updates the systemservice table. 
   */
 private void fillEmptyDays(ResourceBundle rb,Connection conn)
  throws SQLException
 {
//  System.out.println(progName+"( updateServerService): executing ...");
  String sql_str="select a.id,b.serviceid,a.hostname from servers a,systemservicestatus b where a.id=b.serverid and a.active=1 order by a.id,b.serviceid;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);
  Statement stmt2=conn.createStatement();
  while(rset.next()) {
   System.out.println("ServerID="+rset.getInt(1)+" ServiceID="+rset.getInt(2)+"...");      
   // form start date till yesterday
   sql_str="select starttime from systemservice where serverid="+rset.getInt(1)+" and serviceid="+rset.getInt(2)+" and active=1;";
   ResultSet rset2=stmt2.executeQuery(sql_str);
   if(!rset2.next()) {
    System.out.println("No entry in systemservice table. Skipping...");
   }
   else {
    System.out.println("Starttime for "+rset.getInt(1)+" and serviceuid="+rset.getInt(2)+" is "+rset2.getTimestamp(1));
    insertMessage(rb,conn,rset.getInt(1),rset.getString(3),rset.getInt(2),rset2.getTimestamp(1));
   }
  }  
 }

 void insertMessage(ResourceBundle rb,Connection conn,int systemid,String systemName,int serviceid,java.sql.Timestamp startTimestamp)
	throws SQLException
 {
  String dir_str=rb.getString("SISIYAReport.html_dir");
  Calendar cal=Calendar.getInstance();
  cal.add(Calendar.DATE,-1); 
  java.util.Date yesterday=cal.getTime();  
  java.util.Date startDate=startTimestamp;;
  String currentDateString;
    
  PreparedStatement pstmt=conn.prepareStatement("insert into serverhistorystatusall values(?,"+systemid+","+serviceid+",3,?,?)");

  for(java.util.Date d=yesterday;d.compareTo(startDate) >= 0;cal.add(Calendar.DATE,-1),d=cal.getTime()) {
     currentDateString=getDateString(d);
     System.out.print("Checking for "+systemid+" and serviceuid="+serviceid+" date="+currentDateString+"...");
     boolean insert_flag=false;
     File f=new File(dir_str+File.separatorChar+systemName+File.separatorChar+currentDateString+"_service_"+serviceid+"_contents.html");
     if(f.exists()) {
       if(f.length() == 0) {
         f.delete();
         insert_flag=true;
       }
       else
        System.out.println("Skipping");
       continue;
     }
     else {
         insert_flag=true;
     }
     if(insert_flag == true) {
       System.out.println("Inserting one record "+d);
       Timestamp t=new Timestamp(d.getTime());
       pstmt.setTimestamp(1,t);
       pstmt.setTimestamp(2,t);
       pstmt.setString(3,"There was a problem for this service");
       try { pstmt.execute(); }
       catch(SQLException e) { System.err.println(progName+":(insertMessage):"+e.getMessage()); }
     }
  }
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
   * generateHostServisSHSLinks : Generates the Server History Status for every host and service (host_service_sid.html files from
   * serverhistorystatusall table. And populate serversdates table.
   */
 public void generateHostServiceSHSLinks(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String sql_str="select a.id,b.serviceid from servers a,systemservice b where a.id=b.serverid and a.active=b.active and a.active=1 order by a.id,b.serviceid;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);

  while(rset.next()) {
   generateServerServiceStartTimes(conn,rset.getInt(1),rset.getInt(2));      
  }
 }
 
 /**
   * generateServerServiceStartTimes: Populates systemservicestarttimes file.
   */
 private void generateServerServiceStartTimes(Connection conn,int serverid,int serviceid)
  throws SQLException
 {
  /*java.util.Date firstDate=getFirstDate(conn,serverid,serviceid);
   if(firstDate == null)
    System.err.println("No record for ("+serverid+","+serviceid+")");
   else
    System.out.println("First date for ("+serverid+","+serviceid+"):"+firstDate);
  return;
*/
/*
  String sql_str="select a.id,b.serviceid from servers a,systemservice b where a.id=b.serverid and a.active=b.active and a.active=1 order by a.id,b.serviceid;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);

  java.util.Date d;
  while(rset.next()) {
   d=getFirstDate(conn,rset.getInt(1),rset.getInt(2));      
   if(d == null)
    System.err.println("No record for ("+serverid+","+serviceid+")");
   else
    System.out.println("First date for ("+serverid+","+serviceid+"):"+d);
  }
*/
 }

 /**
   * getFirstTimestamp: Finds the first date for this server-service from serverhistorystatusall or serverhistorystatus.
   */
 private java.sql.Timestamp getFirstTimestamp(Connection conn,int serverid,int serviceid)
  throws SQLException
 {
  String sql_str="select sendtime from serverhistorystatusall where serverid="+serverid+" and serviceid="+serviceid+" order by sendtime;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);

  if(rset.next()) {
   return(rset.getTimestamp(1));
  }
  else {
   sql_str="select sendtime from serverhistorystatus where serverid="+serverid+" and serviceid="+serviceid+" order by sendtime;";
   rset=stmt.executeQuery(sql_str);
   if(rset.next())
    return(rset.getTimestamp(1));
   else
    return(null); // there is no record for this (serverid,serviceid)
  }
 }

}	  
