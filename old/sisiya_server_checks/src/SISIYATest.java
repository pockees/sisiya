import java.sql.*;
import java.io.*;
import java.text.*;
import java.util.*;
import java.net.*;
 
/**
  * SMTTest. Generates HTML reports from a SMT Database.
  * @version 0.1 20.12.2003
  * @author Erdal MUTLU
  */ 
public class SMTTest 
{
 final static String progName="SMTTest";
 final static String rbName="SMT";
 int choice=0; // 2^0=serverstatus, 2^1=serverservericestatus, 2^3=serverhistorystatus 2^4=serverhistorystatusall


 public static void main(String args[])
  throws SQLException
 {

  if(args.length != 2) {
     System.err.println("Usage   : "+progName+"locale report_choice");
     System.err.println("Example : "+progName+"en 3");
     System.err.println("2^0=serverstatus, 2^1=serverservericestatus, 2^2=serverhistorystatus, 2^3=serverInfo");
     System.exit(1);
  }
  SMTTest smtreport=new SMTTest();

  
  ResourceBundle rb=null;
  String locale_str="null";
  String jdbc_driver_str=null;
  String jdbc_url_str=null;
  String user_str=null;
  String password_str=null;
  String charset_str=null;
  Connection connection=null; 


  locale_str=new String(args[0]);
  smtreport.choice=(new Integer(args[1])).intValue();

  Locale locale=new Locale(locale_str,locale_str.toUpperCase());
  rb=ResourceBundle.getBundle(rbName,locale);
  
  jdbc_driver_str=rb.getString(rbName+".jdbc_driver");
  jdbc_url_str=rb.getString(rbName+".jdbc_url");
  user_str=rb.getString(rbName+".user");
  password_str=rb.getString(rbName+".password");
 
  PrintWriter out=new PrintWriter(System.out,true);

  boolean errorFlag=false; 
  try {
      connection=smtreport.loginToDB(out,jdbc_driver_str,jdbc_url_str,user_str,password_str); 
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
  smtreport.generateIndex(rb,connection);
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
   * generateIndex : Generates the index_detailed.html file.
   */
 public void generateIndex(ResourceBundle rb,Connection conn)
  throws SQLException
 {
  String sql_str="select * from serverhistorystatus;";
  Statement stmt=conn.createStatement();
  ResultSet rset=stmt.executeQuery(sql_str);
  ResultSetMetaData rsmd = rset.getMetaData();
  int numberOfColumns=rsmd.getColumnCount();

  while(rset.next()) {
    for(int i=1;i<=numberOfColumns;i++)
      System.out.print(rset.getString(i)); 
    System.out.println();
  }
 }
}	  
