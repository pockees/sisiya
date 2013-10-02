import java.sql.*;
import java.io.*;
//import java.text.*;
import java.util.*;
import java.net.*;

/**
  * SISIYAInsertMessage. Insert message in a SISIYA Database.
  * @version 0.1 31.01.2004
  * @author Erdal MUTLU
  */
public class SISIYAInsertMessage 
{
 final static String progName="SISIYAInsertMessage";
 final static String rbName="SISIYA";
   
 ResourceBundle rb;
 String locale_str;
 String jdbcDriver;
 String jdbcURL;
 String user;
 String password;
 String charset_str;
 Connection connection=null; 

 PrintWriter out;

 String systemID,serviceID,statusID;
 String hostName,msg;
 Timestamp sendTimestamp;


 public static void main(String args[])
  throws SQLException
 {
  if(args.length != 1) {
     System.err.println("Usage   : "+progName+"message");
     System.err.println("Example : "+progName+"~1~2~helvetica~20040131135721~Hallo from helvetica");
     System.err.println("2^0=serverstatus, 2^1=serverservericestatus, 2^3=serverhistorystatus, 2^4=serverInfo");
     System.exit(1);
  }
  SISIYAInsertMessage sisiyaim=new SISIYAInsertMessage();
  
/*
if(sisiyaim.connect() == false)
   return(1);
  
  return(sisiyaim.insert(new String(args[0])));
  */
  
  if(sisiyaim.connect() == false)
   System.exit(1);

  System.exit(sisiyaim.insert(new String(args[0])));
 }		       
 
 /**
   * Default constructor.
   */
 public SISIYAInsertMessage()
 {
  rb=ResourceBundle.getBundle(rbName);
  jdbcDriver=rb.getString(rbName+".jdbc_driver");
  jdbcURL=rb.getString(rbName+".jdbc_url");
  user=rb.getString(rbName+".user");
  password=rb.getString(rbName+".password");
 
  out=new PrintWriter(System.out,true);
 } 

 /**
   * connection : Coonects to the database.
   */
  public boolean connect()
  {
   boolean errorFlag=false; 

   try {
       loginToDB(); 
   }
   catch(SQLException e) {
      errorFlag=true; 
      out.println(progName+"(connect): SQLException caught");
      while(e != null) {
        out.println(progName+"(connect): SQL State :"+e.getSQLState());
        out.println(progName+"(connect): Message   :"+e.getMessage());
        out.println(progName+"(connect): Error Code:"+e.getErrorCode());
        e=e.getNextException();
      }
     }
   catch(ConnectException e) {
      errorFlag=true; 
      out.println(progName+"(connect): ConnectException caught");
      out.println(progName+"(connect): Message :"+e.getLocalizedMessage());
   }  
   if(errorFlag) {
   //  System.err.println(progName+"(connect): Connection error!");
     return(false);
   }
   return(true);
  }

 /**
   * loginToDB : Creates a connection to the database.
   */
 public void loginToDB()
  throws SQLException, ConnectException
 {
  if(connection == null || connection.isClosed()) {
   // Load the JDBC driver
    try {
       Class.forName(jdbcDriver).newInstance();  
    }
    catch(Exception E) { 
     out.println(progName+"(loginToDB):Unable to load the "+jdbcDriver+" JDBC driver");
     E.printStackTrace();
    }
    connection=DriverManager.getConnection(jdbcURL,user,password);
  }
 /*
  DatabaseMetaData dbmd=connection.getMetaData();
  out.println(progName+" :(loginToDB): Database Product Name    : "+dbmd.getDatabaseProductName());
  out.println(progName+" :(loginToDB): Database Product Version : "+dbmd.getDatabaseProductVersion());
  out.println(progName+" :(loginToDB): Driver Name              : "+dbmd.getDriverName());
  out.println(progName+" :(loginToDB): Driver Version           : "+dbmd.getDriverVersion());
  out.println(progName+" :(loginToDB): Driver Major Verion      : "+dbmd.getDriverMajorVersion());
  out.println(progName+" :(loginToDB): Driver Minor Version     : "+dbmd.getDriverMinorVersion());
  */
 }

 /**
   * insert: Inserts a message into the database. Returns 0 on success, 1 on error.
   */
 public int insert(String message)
  throws SQLException
 {
  extractFields(message);  

  if(getSystemID() == false) {
   System.err.println(progName+":(getSystemID): No such system "+hostName);
   System.exit(1);
  } 
  //System.out.println("systemID="+systemID);
  
  // for serverhistorystatus table
  PreparedStatement pstmt=connection.prepareStatement("insert into serverhistorystatus values(?,"+systemID+","+serviceID+","+statusID+",now(),?);");
  pstmt.setTimestamp(1,sendTimestamp);
  pstmt.setString(2,msg);
  //System.out.println("pstmt"+pstmt.toString()); 
  if(pstmt.executeUpdate() != 1) 
    return(1);
 
  // for serverservice table
  Statement stmt=connection.createStatement();
  ResultSet rset=stmt.executeQuery("select statusid from serverservicestatus where serverid="+systemID+" and serviceid="+serviceID+";");
  if(rset.next()) {
   if(statusID.compareTo(rset.getString(1)) !=0) {
     pstmt=connection.prepareStatement("update serverservicestatus set statusid="+statusID+",changetime=?,updatetime=?,str=? where serverid="+systemID+" and serviceid="+serviceID+";"); 
     pstmt.setTimestamp(1,sendTimestamp);
     pstmt.setTimestamp(2,sendTimestamp);
     pstmt.setString(3,msg);
   }
   else {
     pstmt=connection.prepareStatement("update serverservicestatus set statusid="+statusID+",updatetime=?,str=? where serverid="+systemID+" and serviceid="+serviceID+";"); 
     pstmt.setTimestamp(1,sendTimestamp);
     pstmt.setString(2,msg);
   }
  }
  else {
   // new record
   pstmt=connection.prepareStatement("insert into serverservicestatus values("+systemID+","+serviceID+","+statusID+",?,?,?);");
   pstmt.setTimestamp(1,sendTimestamp);
   pstmt.setTimestamp(2,sendTimestamp);
   pstmt.setString(3,msg);
  }
  //System.out.println("pstmt="+pstmt);  
  if(pstmt.executeUpdate() != 1)
    return(1);
 
  // for serverstatus table
  rset=stmt.executeQuery("select statusid from serverstatus where serverid="+systemID+";");
  if(rset.next()) {
    String systemStatusID=rset.getString(1);
    String maxStatusID=getMaxStatusID();
    //System.out.println("maxStatusID="+maxStatusID);
    
    if((new Integer(maxStatusID)).intValue() < 2) {
      // System is OK
      //System.out.println("System is OK");
      pstmt=connection.prepareStatement("update serverstatus set updatetime=?,str=? where serverid="+systemID+";");
      pstmt.setTimestamp(1,sendTimestamp);
      pstmt.setString(2,"System is OK");
    }
    else {
     // System has warnings and/or errors
      //System.out.println("System has warnings and/or errors");
      // get all errors and/or warnings
      rset=stmt.executeQuery("select b.str,c.str from serverservicestatus a,services b,status c where a.serviceid=b.id and a.statusid=c.id and serverid="+systemID+" and c.id > 1 order by statusid desc;");
      StringBuffer sb=new StringBuffer("");
      while(rset.next()) {
       sb.append(rset.getString(1)+"("+rset.getString(2)+") ");
      }
      //System.out.println("sb="+sb.toString());
      if(maxStatusID.compareTo(systemStatusID) != 0) {
        if(maxStatusID.compareTo(statusID) == 0) {
         pstmt=connection.prepareStatement("update serverstatus set statusid="+maxStatusID+",changetime=?,updatetime=?,str=? where serverid="+systemID+";");
	 pstmt.setTimestamp(1,sendTimestamp);
	 pstmt.setTimestamp(2,sendTimestamp);
	 pstmt.setString(3,sb.toString());
	}
	else {
         pstmt=connection.prepareStatement("update serverstatus set statusid="+maxStatusID+",updatetime=?,str=? where serverid="+systemID+";");
	 pstmt.setTimestamp(1,sendTimestamp);
	 pstmt.setString(2,sb.toString());
	}
      }
      else {
      /*
        if(statusID.compareTo(systemStatusID) == 0) {
         pstmt=connection.prepareStatement("update serverstatus set updatetime=?,str=? where serverid="+systemID+";");
	 pstmt.setTimestamp(1,sendTimestamp);
	 pstmt.setString(2,sb.toString());
	}
	else {
         pstmt=connection.prepareStatement("update serverstatus set updatetime=? where serverid="+systemID+";");
	 pstmt.setTimestamp(1,sendTimestamp);
	}
	*/
         pstmt=connection.prepareStatement("update serverstatus set updatetime=?,str=? where serverid="+systemID+";");
	 pstmt.setTimestamp(1,sendTimestamp);
	 pstmt.setString(2,sb.toString());
      }
    }
  }
  else {
  // new record
   pstmt=connection.prepareStatement("insert into serverstatus values("+systemID+","+statusID+",?,?,?);");
   pstmt.setTimestamp(1,sendTimestamp);
   pstmt.setTimestamp(2,sendTimestamp);
   pstmt.setString(3,msg);
  }

//  System.out.println("pstmt="+pstmt);
  if(pstmt.executeUpdate() != 1)
    return(1);
  else
    return(0);
 }

 /**
   * extractField: Extract fields from the message.
   */
 private void extractFields(String message)
 {
  String[] strArray=message.split(message.substring(0,1));
/*
  for(int i=0;i<strArray.length;i++) {
    System.out.println(i+":"+strArray[i]);
  }
*/
  serviceID=strArray[1];
  statusID=strArray[2];
  hostName=strArray[3];
  msg=strArray[5];
  sendTimestamp=getTimestamp(strArray[4]);

 // System.out.println("serviceID :"+serviceID+" statusID:"+statusID+" hostName:"+hostName+" dateString:"+sendTimestamp+" msg:"+msg);
 }

 /**
   *
   */
 private Timestamp getTimestamp(String str)
 {
  int year,month,day,hour,minute,second;
  
  year=(new Integer(str.substring(0,4))).intValue();
  month=(new Integer(str.substring(5,7))).intValue();
  day=(new Integer(str.substring(8,10))).intValue();
  hour=(new Integer(str.substring(11,13))).intValue();
  minute=(new Integer(str.substring(14,16))).intValue();
  second=(new Integer(str.substring(17,19))).intValue();
  
  Calendar cal=Calendar.getInstance();
  
  cal.set(year,month-1,day,hour,minute,second);
  
  //System.out.println("year="+year+" month="+month+" day="+day+" hour="+hour+" minute="+minute+" second="+second);
  return(new Timestamp(cal.getTimeInMillis()));
 }
 
 /**
   *
   */
 private boolean getSystemID()
  throws SQLException
 {
  PreparedStatement pstmt;
  if(hostName.indexOf('.') == -1)
   pstmt=connection.prepareStatement("select id from servers where hostname=?;");
  else
   pstmt=connection.prepareStatement("select id from servers where fullhostname=?;");

  pstmt.setString(1,hostName);
  ResultSet rset=pstmt.executeQuery();

  if(rset.next()) { 
    systemID=rset.getString(1);
    return(true);
  }  
  else
   return(false);
 }
 
 /**
   * getMaxStatusID: Finds the maximum statusID for a given system.
   */
 private String getMaxStatusID()
  throws SQLException
 {
  Statement stmt=connection.createStatement();
  ResultSet rset=stmt.executeQuery("select max(statusid) from serverservicestatus where serverid="+systemID+";");
  
  if(rset.next()) 
   return(rset.getString(1));
  else
   return("0");
   
 }
 
}
