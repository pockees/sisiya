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
	final static String progName = "SISIYACheckDB";
	final static String rbName = "SISIYACheckDB";
	final int status_ok = 0;
	final int status_error = 1; 

	String server_str;

	ResourceBundle rb_server;
 
	String jdbc_driver_str = null;
	String jdbc_url_str = null;
	String user_str = null;
	String password_str = null;
	String charset_str = null;

	/*
	* Default constructor
	*/
	SISIYACheckDB(String server_str)
	{
		this.server_str = server_str;

		rb_server = ResourceBundle.getBundle(server_str + "_" + rbName);
	}
 
	public static int main(String args[])
		throws SQLException
	{

		if(args.length != 1) {
			System.err.println("Usage   : " + progName + " server_name");
			System.err.println("Example : " + progName + " db1");
			System.exit(1);
		}

		SISIYACheckDB SISIYAcheckdb = new SISIYACheckDB(args[0]);
		return(SISIYAcheckdb.check());
	}		       

	/*
	* check: Check all DBs speciefied in the server_SISIYACheckDB.properties file.
	*/
	public int check()
	{
		int ndbtypes, i, j, ndbs, serviceid;
		boolean errorFlag; 
  
		PrintWriter err = new PrintWriter(System.err, true);
		String message_str = "";
		statusid = status_error;

		ndbtypes = (new Integer(rb_server.getString(rbName + ".dbtypes_count"))).intValue();
		for (i = 0; i < ndbtypes; i++) {
			ndbs = (new Integer(rb_server.getString(rbName + ".dbtype" + i + "_count"))).intValue();
			String dbtype_str = rb_server.getString(rbName + ".dbtype" + i + "_type");
			String jdbc_driver_str = rb_server.getString(rbName + ".dbtype" + i + "_jdbc_driver");

			try {
				loadDriver(err, jdbc_driver_str);
			}
			catch(SQLException e) {
				errorFlag = true;
				err.println(progName + ": SQLException caught");
				while(e != null) {
					err.println(progName + ": SQL State :" + e.getSQLState());
					err.println(progName + ": Message   :" + e.getMessage());
					err.println(progName + ": Error Code:" + e.getErrorCode());
					e = e.getNextException();
				}
			}
 
			String db_version_str = null; // change this when you fix the problem
	
			StringBuffer sbOk = new StringBuffer();
			StringBuffer sbError = new StringBuffer();
			statusid = status_ok;
			String message = "";
			for(j = 0; j < ndbs; j++) {
				String dbname_str = rb_server.getString(rbName + ".dbtype" + i + "_name_" + j);
				String jdbc_url_str; 

				try {
					jdbc_url_str = rb_server.getString(rbName + ".dbtype" + i + "_jdbc_url_" + j);
				} catch (MissingResourceException E) {
					long port;
					try {
						port = (new Long(rb_server.getString(rbName + ".dbtype" + i + "_port_" + j))).longValue();
					} catch (MissingResourceException EE) {
						port = -1;
					}
					if (port != -1)
						jdbc_url_str = "jdbc:" + dbtype_str + "://" + server_str + ":" + port + "/" + dbname_str;
					else
						jdbc_url_str = "jdbc:" + dbtype_str + "://" + server_str + "/" + dbname_str;
				} 

				String user_str = rb_server.getString(rbName + ".dbtype" + i + "_user_" + j);
				String password_str = rb_server.getString(rbName + ".dbtype" + i + "_password_" + j);
				db_version_str = null;
				errorFlag = false; 
				try {
					db_version_str = loginToDB(err, jdbc_url_str, user_str, password_str); 
				} catch (SQLException e) {
					errorFlag = true; 
					err.println(progName + ": SQLException caught");
					while(e != null) {
						err.println(progName + ": server=" + server_str + " user=" + user_str + " db=" + dbname_str);
						err.println(progName + ": SQL State :" + e.getSQLState());
						err.println(progName + ": Message   :" + e.getMessage());
						err.println(progName + ": Error Code:" + e.getErrorCode());
						e=e.getNextException();
					}
				} catch (ConnectException e) {
					errorFlag = true; 
					err.println(progName + ": ConnectException caught");
					err.println(progName + ": Message :" + e.getMessage());
				}  
				if (errorFlag) {
					statusid = status_error;
					if (sbError.toString().compareTo("") == 0)
						sbError.append("ERROR:");
					sbError.append(" " + user_str + "@" + dbname_str);	
				} else { 
					if (sbOk.toString().compareTo("") == 0)
						sbOk.append("OK:");
					sbOk.append(" " + user_str + "@" + dbname_str);	
				} 
			}
			if(statusid == status_ok) 
				message_str = sbOk.toString() + "(" + db_version_str + ")";
			else  
				message_str = sbError.toString() + " " + sbOk.toString();
		}
		System.out.println(message_str);
		return(statusid);
	}

	/**
	* loginToDB : Creates a connection to the database.
	*/
	private String loginToDB(PrintWriter err, String connect, String user, String password)
		throws SQLException, ConnectException
	{
		Connection conn;

		conn = DriverManager.getConnection(connect, user, password);
		DatabaseMetaData dbmd = conn.getMetaData();
		/*
		err.println(progName+" :(loginToDB): Database Product Name    : "+dbmd.getDatabaseProductName());
		err.println(progName+" :(loginToDB): Database Product Version : "+dbmd.getDatabaseProductVersion());
		err.println(progName+" :(loginToDB): Driver Name              : "+dbmd.getDriverName());
		err.println(progName+" :(loginToDB): Driver Version           : "+dbmd.getDriverVersion());
		err.println(progName+" :(loginToDB): Driver Major Verion      : "+dbmd.getDriverMajorVersion());
		err.println(progName+" :(loginToDB): Driver Minor Version     : "+dbmd.getDriverMinorVersion());
		*/
		return(dbmd.getDatabaseProductName() + "(" + dbmd.getDatabaseProductVersion() + ")");
	}

	private void loadDriver(PrintWriter err,String driver)
		throws SQLException
	{
		// Load the JDBC driver
		try {
			Class.forName(driver).newInstance();  
		}
		catch(Exception E) { 
			err.println(progName + ":(loadDriver): Unable to load the " + driver);
			E.printStackTrace();
		}
	} 
}	  
