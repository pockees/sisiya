import java.sql.*;
import java.io.*;
import java.util.*;
import java.net.*;
 
/**
  * SISIYACheckDB. Checks if the connection to the speciefied DBs is OK.
  * @version 0.1 17.03.2004
  * @author Erdal MUTLU
  */ 
public class SISIYACheckDB 
{
	final static String progName="SISIYACheckDB";
	final static String rbName="SISIYACheckDB";
	int status_ok,status_error; 
	// int status_warning,status_info;

	String send_message_prog_str;
	String SISIYA_client_conf_str;
	String expire_str;
	String server_str;

	ResourceBundle rb;
	ResourceBundle rb_server;
 
	String jdbc_driver_str=null;
	String jdbc_url_str=null;
	String user_str=null;
	String password_str=null;
	String charset_str=null;


 /*
  * Default constructor
  */
	SISIYACheckDB(String server_str)
	{
		this.send_message_prog_str=send_message_prog_str;
		this.server_str=server_str;

		rb_server=ResourceBundle.getBundle(server_str+"_"+rbName);
		rb=ResourceBundle.getBundle(rbName);
		SISIYA_client_conf_str=rb.getString("sisiya_client_conf_file");
		expire_str=rb.getString("sisiya_service_expire");
		getStatusCodes();
	}
 
	public static void main(String args[])
		throws SQLException
	{

		if(args.length != 1) {
			System.err.println("Usage   : "+progName+" server_name");
			System.err.println("Example : "+progName+" db1");
			System.exit(1);
		}

 
		SISIYACheckDB SISIYAcheckdb=new SISIYACheckDB(args[0]);
		SISIYAcheckdb.check();
	}		       

 /*
  * check: Check all DBs speciefied in the server_SISIYACheckDB.properties file.
  */
	public void check()
	{
		int ndbtypes,statusid,i,j,ndbs,serviceid;
		boolean errorFlag; 
  
		PrintWriter out=new PrintWriter(System.out,true);

		ndbtypes=(new Integer(rb_server.getString(rbName+".dbtypes_count"))).intValue();
		for(i=0;i<ndbtypes;i++) {
			ndbs=(new Integer(rb_server.getString(rbName+".dbtype"+i+"_count"))).intValue();
			String dbtype_str=rb_server.getString(rbName+".dbtype"+i+"_type");
			String serviceid_name_str=rb_server.getString(rbName+".dbtype"+i+"_serviceid_name");
			serviceid=(new Integer(rb.getString(serviceid_name_str))).intValue(); 
			String jdbc_driver_str=rb_server.getString(rbName+".dbtype"+i+"_jdbc_driver");

			try {
				loadDriver(out,jdbc_driver_str);
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
 
			String db_version_str=null; // chenge this wenn you fix the problem
	
			StringBuffer sbOk=new StringBuffer();
			StringBuffer sbError=new StringBuffer();
			statusid=status_ok;
			String message="";
			for(j=0;j<ndbs;j++) {
				//  System.out.println("("+i+","+j+")");
				String dbname_str=rb_server.getString(rbName+".dbtype"+i+"_name_"+j);
				//    String jdbc_url_str="jdbc:"+dbtype_str+"://"+server_str+"/"+dbname_str;
				// if there is no jdbc_url then construct one. This is needed for example for Oracle
				// Oracle jdbc_url is not like PostgreSQL and MySQL 

				String jdbc_url_str; 
				try {
					jdbc_url_str=rb_server.getString(rbName+".dbtype"+i+"_jdbc_url_"+j);
				}
				catch(MissingResourceException E) {
					long port;
					try {
						port=(new Long(rb_server.getString(rbName+".dbtype"+i+"_port_"+j))).longValue();
					}
					catch(MissingResourceException EE) {
						port=-1;
					}
					if(port != -1)
						jdbc_url_str="jdbc:"+dbtype_str+"://"+server_str+":"+port+"/"+dbname_str;
					else
						jdbc_url_str="jdbc:"+dbtype_str+"://"+server_str+"/"+dbname_str;
				} 

				String user_str=rb_server.getString(rbName+".dbtype"+i+"_user_"+j);
				String password_str=rb_server.getString(rbName+".dbtype"+i+"_password_"+j);
				db_version_str=null;
				errorFlag=false; 
				try {
					db_version_str=loginToDB(out,jdbc_url_str,user_str,password_str); 
				}
				catch(SQLException e) {
					errorFlag=true; 
					out.println(progName+": SQLException caught");
					while(e != null) {
						out.println(progName+": server="+server_str+" user="+user_str+" db="+dbname_str);
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
					statusid=status_error;
					if(sbError.toString().compareTo("") == 0)
						sbError.append("ERROR:");
					sbError.append(" "+user_str+"@"+dbname_str);	
				}
				else { 
					if(sbOk.toString().compareTo("") == 0)
						sbOk.append("OK:");
					sbOk.append(" "+user_str+"@"+dbname_str);	
				} 
			}
			String message_str="";
			if(statusid == status_ok) 
				message_str=sbOk.toString()+"("+db_version_str+")";
			else  
				message_str=sbError.toString()+" "+sbOk.toString();
			message_str = "<msg>" + message_str + "</msg><datamsg></datamsg>";
			String cmd_str=null;
			try {  
				String cmd[]=new String[7];
				cmd[0]=rb.getString("send_message_prog");
				cmd[1]=SISIYA_client_conf_str;
				cmd[2]=server_str;
				cmd[3]=(new Integer(serviceid)).toString();
				cmd[4]=(new Integer(statusid)).toString();
				cmd[5]=expire_str;
				cmd[6]=message_str;
				cmd_str=cmd[0]+" "+cmd[1]+" "+cmd[2]+" "+cmd[3]+" "+cmd[4]+" "+cmd[5]+" "+cmd[6];
				Process ps=Runtime.getRuntime().exec(cmd);  
				//System.out.println("cmd_str=" + cmd_str);
				//    System.out.println("Waiting for the process to terminate ...");
				int retcode=-1;
				try {
					retcode=ps.waitFor();
				}
				catch(InterruptedException E) {
					out.println(progName+":(check): command "+cmd_str+" interrupted");
					E.printStackTrace();
				}
				if(retcode != 0) {
					out.println(progName+":(check): command "+cmd_str+" exited with error!");
				}
			}
			catch(IOException E) {
				out.println(progName+":(check): Unable to execute "+cmd_str);
				E.printStackTrace();
			}
		}
	}
 /*
  * getStatusCodes: Retrieves status codes from SISIYA_client.conf
  */
	private void getStatusCodes()
	{
		status_ok=(new Integer(rb.getString("status_ok"))).intValue();
		status_error=(new Integer(rb.getString("status_error"))).intValue();
	}
 
 /**
   * loginToDB : Creates a connection to the database.
   */
 //public Connection loginToDB(PrintWriter out,String driver,String connect,String user,String password)
	private String loginToDB(PrintWriter out,String connect,String user,String password)
		throws SQLException, ConnectException
	{
		Connection conn;

		conn=DriverManager.getConnection(connect,user,password);
		DatabaseMetaData dbmd=conn.getMetaData();
  /*
  out.println(progName+" :(loginToDB): Database Product Name    : "+dbmd.getDatabaseProductName());
  out.println(progName+" :(loginToDB): Database Product Version : "+dbmd.getDatabaseProductVersion());
  out.println(progName+" :(loginToDB): Driver Name              : "+dbmd.getDriverName());
  out.println(progName+" :(loginToDB): Driver Version           : "+dbmd.getDriverVersion());
  out.println(progName+" :(loginToDB): Driver Major Verion      : "+dbmd.getDriverMajorVersion());
  out.println(progName+" :(loginToDB): Driver Minor Version     : "+dbmd.getDriverMinorVersion());
 */
		return(dbmd.getDatabaseProductName()+"("+dbmd.getDatabaseProductVersion()+")");
	}

	private void loadDriver(PrintWriter out,String driver)
		throws SQLException
	{
		// Load the JDBC driver
		try {
			Class.forName(driver).newInstance();  
		}
		catch(Exception E) { 
			out.println(progName+":(loadDriver): Unable to load the "+driver);
			E.printStackTrace();
		}
	} 
}	  
