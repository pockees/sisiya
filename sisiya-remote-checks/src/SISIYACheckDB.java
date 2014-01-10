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

	String status_ok;
	String status_error; 
	String system_str;
	String expire_str;

	ResourceBundle rb;
	ResourceBundle rb_server;
 
	String jdbc_driver_str = null;
	String jdbc_url_str = null;
	String user_str = null;
	String password_str = null;
	String charset_str = null;

	/*
	* Default constructor
	*/
	SISIYACheckDB(String system_str, String properties_file, String expire_str)
	{
		this.system_str = system_str;
		this.expire_str = expire_str;

		//rb_server = ResourceBundle.getBundle(system_str + "_" + rbName);
		rb_server = ResourceBundle.getBundle(properties_file);
		rb = ResourceBundle.getBundle(rbName);
		getStatusCodes();
	}
 
	public static void main(String args[])
		throws SQLException
	{

		if(args.length != 3) {
			System.err.println("Usage   : " + progName + " system_name system_properties_file expire");
			System.err.println("Example : " + progName + " db1 db1_SISIYACheckDB.properties 10");
			System.exit(1);
		}

		SISIYACheckDB SISIYAcheckdb = new SISIYACheckDB(args[0], args[1], args[2]);
		SISIYAcheckdb.check();
	}		       

	/*
	* check: Check all DBs speciefied in the server_SISIYACheckDB.properties file.
	*/
	public void check()
	{
		int ndbtypes, i, j, ndbs;
		boolean errorFlag; 
  
		PrintWriter err = new PrintWriter(System.err, true);
		StringBuffer messages_sb = new StringBuffer();
		StringBuffer error_message_sb;
		String message_str = "";
		String statusid_str = status_error;

		ndbtypes = (new Integer(rb_server.getString(rbName + ".dbtypes_count"))).intValue();
		for (i = 0; i < ndbtypes; i++) {
			ndbs = (new Integer(rb_server.getString(rbName + ".dbtype" + i + "_count"))).intValue();
			String dbtype_str = rb_server.getString(rbName + ".dbtype" + i + "_type");
			String serviceid_str = rb_server.getString(rbName + ".dbtype" + i + "_serviceid");
			String jdbc_driver_str = rb_server.getString(rbName + ".dbtype" + i + "_jdbc_driver");

			error_message_sb = null;
			try {
				loadDriver(err, jdbc_driver_str);
			}
			catch(SQLException e) {
				errorFlag = true;
				error_message_sb = new StringBuffer();
				error_message_sb.append("SQLException caught:");
				while(e != null) {
					error_message_sb.append(" SQL State :" + e.getSQLState());
					error_message_sb.append(" Message   :" + e.getMessage());
					error_message_sb.append(" Error Code:" + e.getErrorCode());
					e = e.getNextException();
				}
			}
 
			String db_version_str = null; // change this when you fix the problem
	
			StringBuffer sbOk = new StringBuffer();
			StringBuffer sbError = new StringBuffer();
			statusid_str = status_ok;
			String message = "";
			for(j = 0; j < ndbs; j++) {
				String dbname_str = rb_server.getString(rbName + ".dbtype" + i + "_name_" + j);
				String jdbc_url_str; 

				//try {
					jdbc_url_str = rb_server.getString(rbName + ".dbtype" + i + "_jdbc_url_" + j);
				/*} catch (MissingResourceException E) {
					long port;
					try {
						port = (new Long(rb_server.getString(rbName + ".dbtype" + i + "_port_" + j))).longValue();
					} catch (MissingResourceException EE) {
						port = -1;
					}
					if (port != -1)
						jdbc_url_str = "jdbc:" + dbtype_str + "://" + system_str + ":" + port + "/" + dbname_str;
					else
						jdbc_url_str = "jdbc:" + dbtype_str + "://" + system_str + "/" + dbname_str;
				} 
				*/

				String user_str = rb_server.getString(rbName + ".dbtype" + i + "_user_" + j);
				String password_str = rb_server.getString(rbName + ".dbtype" + i + "_password_" + j);
				db_version_str = null;
				errorFlag = false; 
				try {
					db_version_str = loginToDB(err, jdbc_url_str, user_str, password_str); 
				} catch (SQLException e) {
					errorFlag = true; 
					if (error_message_sb == null) 
						error_message_sb = new StringBuffer();
					error_message_sb.append("SQLException caught: ");
					while(e != null) {
						error_message_sb.append(" server=" + system_str + " user=" + user_str + " db=" + dbname_str);
						error_message_sb.append(" SQL State :" + e.getSQLState());
						error_message_sb.append(": Message   :" + e.getMessage());
						error_message_sb.append(": Error Code:" + e.getErrorCode());
						e = e.getNextException();
					}
				} catch (ConnectException e) {
					if (error_message_sb == null) 
						error_message_sb = new StringBuffer();
					errorFlag = true; 
					error_message_sb.append(" ConnectException caught");
					error_message_sb.append(" Message :" + e.getMessage());
				}  
				if (errorFlag) {
					statusid_str = status_error;
					if (sbError.toString().compareTo("") == 0)
						sbError.append("ERROR:");
					sbError.append(" " + user_str + "@" + dbname_str);	
				} else { 
					if (sbOk.toString().compareTo("") == 0)
						sbOk.append("OK:");
					sbOk.append(" " + user_str + "@" + dbname_str);	
				} 
			}
			if(statusid_str.equals(status_ok)) 
				message_str = sbOk.toString() + "(" + db_version_str + ")";
			else  
				message_str = sbError.toString() + error_message_sb.toString() + " " + sbOk.toString();
			messages_sb.append("<message><serviceid>" + serviceid_str + "</serviceid><statusid>" + statusid_str + "</statusid><expire>" + expire_str + "</expire><data><msg>" + message_str + "</msg><datamsg></datamsg></data></message>");
		}
		System.out.println(messages_sb.toString());
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
	/*
	* getStatusCodes: Retrieves status codes from SISIYA_client.conf
	 */
	private void getStatusCodes()
	{
		status_ok=rb.getString("status_ok");
		status_error=rb.getString("status_error");
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
