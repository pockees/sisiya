// You need to import the java.sql package to use JDBC
import java.sql.*;
import java.io.*;
import java.util.*;
import java.net.*;

/**
  * eDBInfo. Get info for a given DB. Used to demontsrate and test JDBC usage.
  * @version 0.1 15.05.2005
  * @author Erdal MUTLU
  */ 

class eDBInfo
{
	final static String progName="eDBInfo";
	final static String rbName="eDBInfo";
	
	ResourceBundle rb=null;
	
	String jdbc_driver_str=null;
	String jdbc_url_str=null;
	String dbtype_str=null;
	String dbname_str=null;
	String server_str=null;
	String user_str=null;
	String password_str=null;

	Connection conn=null;
	DatabaseMetaData dbmd=null;
	PrintWriter out=null;

	/*
	* Default constructor
	*/
	eDBInfo()
	{
		out=new PrintWriter(System.out,true);
		rb=ResourceBundle.getBundle(rbName);
		getRBParams();
		if(loadDriver() == false) {
			System.out.println("eDBInfo::Constructor: Error loading the JDBC driver");
			System.exit(1);
		}
		boolean errorFlag=false; 
		try {
			loginToDB(out,jdbc_url_str,user_str,password_str); 
		}
		catch(SQLException e) {
			errorFlag=true; 
			out.println("eDBInfo::printInfo:: SQLException caught");
			while(e != null) {
				out.println("eDBInfo::printInfo:: server="+server_str+" user="+user_str+" db="+dbname_str);
				out.println("eDBInfo::printInfo:: SQL State :"+e.getSQLState());
				out.println("eDBInfo::printInfo:: Message   :"+e.getMessage());
				out.println("eDBInfo::printInfo:: Error Code:"+e.getErrorCode());
				e=e.getNextException();
			}
		}
		catch(ConnectException e) {
			errorFlag=true; 
			out.println("eDBInfo::printInfo:: ConnectException caught");
			out.println("eDBInfo::printInfo:: Message :"+e.getMessage());
		}
		if(errorFlag == true) {
			out.println("eDBInfo::Constructor: Error connecting to the DB.");
			System.exit(1);
		}
	}
	
	void getRBParams()
	{
		dbname_str=rb.getString(rbName+".dbname");
		jdbc_driver_str=rb.getString(rbName+".jdbc_driver");
		dbtype_str=rb.getString(rbName+".dbtype");
		server_str=rb.getString(rbName+".dbserver");
		System.out.println("dbname="+dbname_str);
		jdbc_url_str="jdbc:"+dbtype_str+"://"+server_str+"/"+dbname_str;
		user_str=rb.getString(rbName+".dbuser");
		password_str=rb.getString(rbName+".dbpassword");
		System.out.println("jdbc_driver="+jdbc_driver_str);
		System.out.println("jdbc_url="+jdbc_url_str);
		System.out.println("user="+user_str);
		System.out.println("password="+password_str);
	}

	boolean loadDriver()
	{
		boolean errorFlag=false;	
		try {
			loadDriver(out,jdbc_driver_str);
		}
		catch(SQLException e) {
			errorFlag=true;
			out.println("eDBInfo::printInfo:: SQLException caught");
			while(e != null) {
				out.println("eDBInfo::printInfo:: SQL State :"+e.getSQLState());
				out.println("eDBInfo::printInfo:: Message   :"+e.getMessage());
				out.println("eDBInfo::printInfo:: Error Code:"+e.getErrorCode());
				e=e.getNextException();
			}
		}
		return(!errorFlag);
	}

	private void loadDriver(PrintWriter out,String driver)
		throws SQLException
	{
		// Load the JDBC driver
		try {
			Class.forName(driver).newInstance();  
		}
		catch(Exception E) { 
			out.println("eDBInfo::printInfo::(loadDriver): Unable to load the "+driver);
			E.printStackTrace();
		}
	} 

	void printDBInfo()
	{
		try {	
			out.println("eDBInfo::printInfo: Database Product Name    : "+dbmd.getDatabaseProductName());
			out.println("eDBInfo::printInfo: Database Product Version : "+dbmd.getDatabaseProductVersion());
			out.println("eDBInfo::printInfo: Driver Name              : "+dbmd.getDriverName());
			out.println("eDBInfo::printInfo: Driver Version           : "+dbmd.getDriverVersion());
			out.println("eDBInfo::printInfo: Driver Major Verion      : "+dbmd.getDriverMajorVersion());
			out.println("eDBInfo::printInfo: Driver Minor Version     : "+dbmd.getDriverMinorVersion());

			String dbmsName=dbmd.getDatabaseProductName();
			ResultSet rs=dbmd.getTableTypes(); 
			System.out.print("The following are available tables types ");
			System.out.println(" available in "+dbmsName+": ");
			while(rs.next()) {
				String tableType=rs.getString("TABLE_TYPE");
				System.out.println("  "+tableType);    
			}
			rs=dbmd.getCatalogs(); 
			System.out.print("The catalogs are available ");
			System.out.println(" available in "+dbmsName+": ");
			while(rs.next()) {
				String catalogType=rs.getString("TABLE_CAT");
				System.out.println("  "+catalogType);    
			}
			System.out.println("Are all procedures callable : "+dbmd.allProceduresAreCallable());
			System.out.println("Catalog separator 		: "+dbmd.getCatalogSeparator());
			System.out.println("Catalog term 		: "+dbmd.getCatalogTerm());
			System.out.println("Are all tables selectable   : "+dbmd.allTablesAreSelectable());
			System.out.print("Database's default isolation level	: "+dbmd.getDefaultTransactionIsolation());
			switch(dbmd.getDefaultTransactionIsolation()) {
				case java.sql.Connection.TRANSACTION_NONE :
					System.out.println(" TRANSACTION_NONE");
					break;
				case java.sql.Connection.TRANSACTION_READ_COMMITTED :
					System.out.println(" TRANSACTION_READ_COMMITTED");
					break;
				case java.sql.Connection.TRANSACTION_READ_UNCOMMITTED :
					System.out.println(" TRANSACTION_READ_UNCOMMITTED");
					break;
				case java.sql.Connection.TRANSACTION_REPEATABLE_READ :
					System.out.println(" TRANSACTION_REPEATABLE_READ");
					break;
				case java.sql.Connection.TRANSACTION_SERIALIZABLE :
					System.out.println(" TRANSACTION_SERIALIZABLE");
					break;
				default :
					System.out.println(" unknown");
					break;
			}
			System.out.println("Whether a data definition statement within a transaction forces the transaction to commit : "+dbmd.dataDefinitionCausesTransactionCommit());
			System.out.println("Whether this database ignores a data definition statement within a transaction : "+dbmd.dataDefinitionIgnoredInTransactions());
			System.out.println("Whether the return value for the method getMaxRowSize includes the SQL data types LONGVARCHAR and LONGVARBINARY : "+dbmd.doesMaxRowSizeIncludeBlobs());
			System.out.println("Extra characters that can be used in unquoted indentifier names : "+dbmd.getExtraNameCharacters());
			System.out.println("String used to quote SQL strings : "+dbmd.getIdentifierQuoteString());
			System.out.println("Max number of characters this database allows in an inline binary literal (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxBinaryLiteralLength());
			System.out.println("Max number of characters this database allows in a catalog name (if 0 => no limit or the limit is unknown)  : "+dbmd.getMaxCatalogNameLength());
			System.out.println("Max number of characters this database allows for a character literal (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxCharLiteralLength());
			System.out.println("Max number of characters this database allows for a column name (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxColumnNameLength());
			System.out.println("Max number of columns this database allows in a GROUP BY clause (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxColumnsInGroupBy());
			System.out.println("Max number of columns this database allows in an index (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxColumnsInIndex());
			System.out.println("Max number of columns this database allows in a ORDER BY clause (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxColumnsInOrderBy());
			System.out.println("Max number of columns this database allows in a SELECT list (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxColumnsInSelect());
			System.out.println("Max number of columns this database allows in a table (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxColumnsInTable());
			System.out.println("Max number of number of concurrent connections to this database that are possible (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxConnections());
			System.out.println("Max number of characters that this database allows in a cursor name (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxCursorNameLength());
			System.out.println("Max number of bytes this database allows for an index, including all of the parts of the index (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxIndexLength());
			System.out.println("Max number of characters that this database allows in a procedure name (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxProcedureNameLength());
			System.out.println("Max number of bytes this database allows in a single row (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxRowSize());
			System.out.println("Max number of characters that this database allows in a schema name (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxSchemaNameLength());
			System.out.println("Max number of characters this database allows in an SQL statement (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxStatementLength());
			System.out.println("Max number of active statements to this database that can be open at the same time (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxStatements());
			System.out.println("Max number of characters this database allows in a table name (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxTableNameLength());
			System.out.println("Max number of tables this database allows in a SELECT statement (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxTablesInSelect());
			System.out.println("Max number of characters this database allows in a user name (if 0 => no limit or the limit is unknown) : "+dbmd.getMaxUserNameLength());
			System.out.println("Comma-separated list of math functions available with this database : "+dbmd.getNumericFunctions());
			System.out.println("The database vendor's preferred term for \"procedure\": "+dbmd.getProcedureTerm());
			System.out.print("The default holdability of this ResultSet  object : "+dbmd.getResultSetHoldability());
			switch(dbmd.getResultSetHoldability()) {
				case ResultSet.HOLD_CURSORS_OVER_COMMIT :
					System.out.println(" HOLD_CURSORS_OVER_COMMIT");
					break;
				case ResultSet.CLOSE_CURSORS_AT_COMMIT :
					System.out.println(" CLOSE_CURSORS_AT_COMMIT");
					break;
				default :
					System.out.println(" unknown holdability");
					break;
			}
			System.out.println("The database vendor's preferred term for \"schema\": "+dbmd.getSchemaTerm());
			System.out.println("The string that can be used to escape wildcard characters : "+dbmd.getSearchStringEscape());
			System.out.println("A comma-separated list of all of this database's SQL keywords that are NOT also SQL92 keywords : "+dbmd.getSQLKeywords());
			System.out.print("Indicates whether the SQLSTATE returned by SQLException.getSQLState  is X/Open (now known as Open Group) SQL CLI or SQL99 : "+dbmd.getSQLStateType());
			switch(dbmd.getSQLStateType()) {
				case DatabaseMetaData.sqlStateXOpen :
					System.out.println(" sqlStateXOpen");
					break;
				case DatabaseMetaData.sqlStateSQL99 :
					System.out.println(" sqlStateSQL99");
					break;
				default :
					System.out.println(" unknown sql state type");
					break;
			}

			System.out.println("A comma-separated list of system functions available with this database : "+dbmd.getSystemFunctions());
			System.out.println("A comma-separated list of the time and date functions available with this database : "+dbmd.getTimeDateFunctions());
//			System.out.println("A description of all the standard SQL types supported by this database : "+dbmd.getTypeInfo());
			System.out.println("The URL for this DBMS : "+dbmd.getURL());
			System.out.println("The user name as known to this database : "+dbmd.getUserName());
			System.out.println("Whether a catalog appears at the start of a fully qualified table name : "+dbmd.isCatalogAtStart());
			System.out.println("Whether this database is in read-only mode : "+dbmd.isReadOnly());
			System.out.println("Whether updates made to a LOB are made on a copy or directly to the LOB : "+dbmd.locatorsUpdateCopy());
			System.out.println("Whether this database supports concatenations between NULL and non-NULL values being NULL : "+dbmd.nullPlusNonNullIsNull());
			System.out.println("Whether NULL values are sorted at the end regardless of sort order : "+dbmd.nullsAreSortedAtEnd());
			System.out.println("Whether NULL values are sorted at the start regardless of sort order : "+dbmd.nullsAreSortedAtStart());
			System.out.println("Whether NULL values are sorted high : "+dbmd.nullsAreSortedHigh());
			System.out.println("Whether NULL values are sorted low : "+dbmd.nullsAreSortedLow());
//			System.out.println("Whether deletes made by others are visible : "+dbmd.othersDeletesAreVisible());
			System.out.println("Whether this database treats mixed case unquoted SQL identifiers as case insensitive and stores them in lower case : "+dbmd.storesLowerCaseIdentifiers());
			System.out.println("Whether this database treats mixed case quoted SQL identifiers as case insensitive and stores them in lower case : "+dbmd.storesLowerCaseQuotedIdentifiers());
			System.out.println("Whether this database treats mixed case unquoted SQL identifiers as case insensitive and stores them in mixed case : "+dbmd.storesMixedCaseIdentifiers());
			System.out.println("Whether this database treats mixed case quoted SQL identifiers as case insensitive and stores them in mixed case : "+dbmd.storesMixedCaseQuotedIdentifiers());
			System.out.println("Whether this database treats mixed case unquoted SQL identifiers as case insensitive and stores them in upper case : "+dbmd.storesUpperCaseIdentifiers());
			System.out.println("Whether this database treats mixed case quoted SQL identifiers as case insensitive and stores them in upper case : "+dbmd.storesUpperCaseQuotedIdentifiers());
			System.out.println("Whether this database supports ALTER TABLE  with add column : "+dbmd.supportsAlterTableWithAddColumn());
			System.out.println("Whether this database supports ALTER TABLE  with drop column : "+dbmd.supportsAlterTableWithDropColumn());
			System.out.println("Whether this database supports the ANSI92 entry level SQL grammar : "+dbmd.supportsANSI92EntryLevelSQL());
			System.out.println("Whether this database supports the ANSI92 intermediate SQL grammar supported : "+dbmd.supportsANSI92IntermediateSQL());
			System.out.println("Whether this database supports batch updates : "+dbmd.supportsBatchUpdates());
			System.out.println("Whether a catalog name can be used in a data manipulation statement : "+dbmd.supportsCatalogsInDataManipulation());
			System.out.println("Whether a catalog name can be used in an index definition statement : "+dbmd.supportsCatalogsInIndexDefinitions());
			System.out.println("Whether a catalog name can be used in a privilege definition statement : "+dbmd.supportsCatalogsInPrivilegeDefinitions());
			System.out.println("Whether a catalog name can be used in a procedure call statement : "+dbmd.supportsCatalogsInProcedureCalls());
			System.out.println("Whether a catalog name can be used in a table definition statement : "+dbmd.supportsCatalogsInTableDefinitions());
			System.out.println("Whether this database supports column aliasing : "+dbmd.supportsColumnAliasing());
			System.out.println("Whether this database supports the CONVERT  function between SQL types : "+dbmd.supportsConvert());
			System.out.println("Whether this database supports the ODBC Core SQL grammar : "+dbmd.supportsCoreSQLGrammar());
			System.out.println("Whether this database supports correlated subqueries : "+dbmd.supportsCorrelatedSubqueries());
			System.out.println("Whether this database supports both data definition and data manipulation statements within a transaction : "+dbmd.supportsDataDefinitionAndDataManipulationTransactions());
			System.out.println("Whether this database supports only data manipulation statements within a transaction : "+dbmd.supportsDataManipulationTransactionsOnly());
			System.out.println("Whether, when table correlation names are supported, they are restricted to being different from the names of the tables : "+dbmd.supportsDifferentTableCorrelationNames());
			System.out.println("Whether this database supports expressions in ORDER BY lists : "+dbmd.supportsExpressionsInOrderBy());
			System.out.println("Whether this database supports the ODBC Extended SQL grammar : "+dbmd.supportsExtendedSQLGrammar());
			System.out.println("Whether this database supports full nested outer joins : "+dbmd.supportsFullOuterJoins());
			System.out.println("Whether auto-generated keys can be retrieved after a statement has been executed : "+dbmd.supportsGetGeneratedKeys());
			System.out.println("Whether this database supports some form of GROUP BY clause : "+dbmd.supportsGroupBy());
			System.out.println("Whether this database supports using columns not included in the SELECT statement in a GROUP BY clause provided that all of the columns in the SELECT statement are included in the GROUP BY clause : "+dbmd.supportsGroupByBeyondSelect());
			System.out.println("Whether this database supports using a column that is not in the SELECT statement in a GROUP BY clause : "+dbmd.supportsGroupByUnrelated());
			System.out.println("Whether this database supports the SQL Integrity Enhancement Facility : "+dbmd.supportsIntegrityEnhancementFacility());
			System.out.println("Whether this database supports specifying a LIKE escape clause : "+dbmd.supportsLikeEscapeClause());
			System.out.println("Whether this database provides limited support for outer joins : "+dbmd.supportsLimitedOuterJoins());
			System.out.println("Whether this database supports the ODBC Minimum SQL grammar : "+dbmd.supportsMinimumSQLGrammar());
			System.out.println("Whether this database treats mixed case unquoted SQL identifiers as case sensitive and as a result stores them in mixed case : "+dbmd.supportsMixedCaseIdentifiers());
			System.out.println("Whether this database treats mixed case quoted SQL identifiers as case sensitive and as a result stores them in mixed case : "+dbmd.supportsMixedCaseQuotedIdentifiers());
			System.out.println("Whether it is possible to have multiple ResultSet objects returned from a CallableStatement object simultaneously : "+dbmd.supportsMultipleOpenResults());
			System.out.println("Whether this database allows having multiple transactions open at once (on different connections) : "+dbmd.supportsMultipleTransactions());
          
			System.out.println("Whether this database supports named parameters to callable statements : "+dbmd.supportsNamedParameters());
			System.out.println("Whether columns in this database may be defined as non-nullable : "+dbmd.supportsNonNullableColumns());
			System.out.println("Whether this database supports keeping cursors open across commits : "+dbmd.supportsOpenCursorsAcrossCommit());
			System.out.println("Retrieves whether this database supports keeping cursors open across rollbacks : "+dbmd.supportsOpenCursorsAcrossRollback());
			System.out.println("Whether this database supports keeping statements open across commits : "+dbmd.supportsOpenStatementsAcrossCommit());
			System.out.println("Whether this database supports keeping statements open across rollbacks : "+dbmd.supportsOpenStatementsAcrossRollback());
			System.out.println("Whether this database supports using a column that is not in the SELECT statement in an ORDER BY clause : "+dbmd.supportsOrderByUnrelated());
			System.out.println("Whether this database supports some form of outer join : "+dbmd.supportsOuterJoins());
			System.out.println("Whether this database supports positioned DELETE statements : "+dbmd.supportsPositionedDelete());
			System.out.println("Whether this database supports positioned UPDATE statements : "+dbmd.supportsPositionedUpdate());
//			System.out.println("Whether this database supports the given concurrency type in combination with the given result set typesupportsResultSetConcurrency(int type, int concurrency));
//			System.out.println("supportsResultSetHoldability(int holdability) Retrieves whether this database supports the given result set holdability.
//			System.out.println("supportsResultSetType(int type) Retrieves whether this database supports the given result set type.
			System.out.println("Whether this database supports savepoints : "+dbmd.supportsSavepoints());
			System.out.println("Whether a schema name can be used in a data manipulation statement :"+dbmd.supportsSchemasInDataManipulation());
			System.out.println("Whether a schema name can be used in an index definition statement : "+dbmd.supportsSchemasInIndexDefinitions());
			System.out.println("Whether a schema name can be used in a privilege definition statement : "+dbmd.supportsSchemasInPrivilegeDefinitions());
			System.out.println("Whether a schema name can be used in a procedure call statement : "+dbmd.supportsSchemasInProcedureCalls());
			System.out.println("Whether a schema name can be used in a table definition statement : "+dbmd.supportsSchemasInTableDefinitions());
			System.out.println("Whether this database supports SELECT FOR UPDATE statements : "+dbmd.supportsSelectForUpdate());
			System.out.println("Whether this database supports statement pooling : "+dbmd.supportsStatementPooling());
			System.out.println("Whether this database supports stored procedure calls that use the stored procedure escape syntax : "+dbmd.supportsStoredProcedures());
			System.out.println("Whether this database supports subqueries in comparison expressions : "+dbmd.supportsSubqueriesInComparisons());
			System.out.println("Whether this database supports subqueries in EXISTS expressions : "+dbmd.supportsSubqueriesInExists());
			System.out.println("Whether this database supports subqueries in IN statements : "+dbmd.supportsSubqueriesInIns());
			System.out.println("Whether this database supports subqueries in quantified expressions : "+dbmd.supportsSubqueriesInQuantifieds());
			System.out.println("Whether this database supports table correlation names : "+dbmd.supportsTableCorrelationNames());
//			System.out.println("supportsTransactionIsolationLevel(int level) Retrieves whether this database supports the given transaction isolation level.
			System.out.println("Whether this database supports transactions : "+dbmd.supportsTransactions());
			System.out.println("Whether this database supports SQL UNION : "+dbmd.supportsUnion());
			System.out.println("Whether this database supports SQL UNION ALL : "+dbmd.supportsUnionAll());
//			System.out.println("updatesAreDetected(int type) Retrieves whether or not a visible row update can be detected by calling the method ResultSet.rowUpdated.
			System.out.println("Whether this database uses a file for each table : "+dbmd.usesLocalFilePerTable());
			System.out.println("Whether this database stores tables in a local file : "+dbmd.usesLocalFiles());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
//			System.out.println(" : "+dbmd.());
		}
		catch(SQLException e) {
			out.println("eDBInfo::printInfo: Caught SQLException : ");
			while(e != null) {
					out.println("eDBInfo::printInfo: SQL State :"+e.getSQLState());
					out.println("eDBInfo::printInfo: Message   :"+e.getMessage());
					out.println("eDBInfo::printInfo: Error Code:"+e.getErrorCode());
					e=e.getNextException();
			}

		}
	}

	private void loginToDB(PrintWriter out,String connect,String user,String password)
		throws SQLException, ConnectException
	{
		conn=DriverManager.getConnection(connect,user,password);
		dbmd=conn.getMetaData(); 
	}

	public static void main(String args [])
		throws SQLException
	{
		eDBInfo edb=new eDBInfo();
		edb.printDBInfo();
	
		// Create a Statement
		/*Statement stmt=conn.createStatement();

		ResultSet rset=stmt.executeQuery ("select * from "+table_str);

		ResultSetMetaData rsmd=rset.getMetaData();
		// Iterate through the result and print the employee names

		*/
		/*    while (rset.next ())
		System.out.println (rset.getString (1)+" "+rset.getString (2)+" "+rset.getString(3));
		*/
/*
		int n=rsmd.getColumnCount();
		System.out.println("Column count = "+n);
		for(int i=1;i<=n;i++)
			System.out.print(rsmd.getColumnName(i)+" ");             
			System.out.println("\n------------------------------------------------------");

		int row=0;
		while(rset.next()) {
			row++;
			System.out.print("Row("+row+"): ");
 
			for(int i=1;i<=n;i++)
				System.out.print (rset.getString(i)+" ");             
				System.out.println();
			}
		}
*/
	}
}
