import java.io.*;
import java.util.*;
import java.net.*;
 
/**
  * SisIYASendMessage. Sends message(s) to the SisIYA server.
  * @version 0.1 26.10.2009
  * @author Erdal MUTLU

    Copyright (C) 2009  Erdal Mutlu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  */ 
public class SisIYASendMessage
{
	final static String progName="SisIYASendMessage";

	int sisiyaPort;
	String sisiyaServer;
	String messageArgument;
	Socket sisiyaSocket;

	/*
	  * Default constructor
	*/
	SisIYASendMessage(String server_str,Integer port,String msg_str)
	{
		this.sisiyaPort=port;
		this.sisiyaServer=server_str;
		this.messageArgument=msg_str;
		this.sisiyaSocket=null;
	
		// open a connection to the SisIYA server
		try {
			this.sisiyaSocket=new Socket(this.sisiyaServer,this.sisiyaPort);
		}
		catch(UnknownHostException e) {
			System.err.println("SisIYASendMessage: Unknown host "+sisiyaServer+" "+e.getLocalizedMessage());
			System.exit(1);
		}
		catch(IOException e) {
			System.err.println("SisIYASendMessage: I/O error "+e.getLocalizedMessage());
			System.exit(1);
		}
	}

	private boolean isFile(String fileName)
	{
		BufferedReader bfrFile=null;
		try {
			bfrFile=new BufferedReader(new FileReader(fileName));
		}
		catch(FileNotFoundException e) {
			return false;
		}
		try {
			bfrFile.close();
		}
		catch(IOException e) {
			System.err.println("isFile: Error closing file "+fileName+" Message:"+e.getLocalizedMessage());
			return false;
		}
		return true;
	}

	private boolean sendMessage(String msg_str)
	{
		PrintWriter out=null;

		try {
			out=new PrintWriter(sisiyaSocket.getOutputStream(),true);
		}
		catch(UnknownHostException e) {
			System.err.println("sendMessage: Don't know about the SisIYA server "+sisiyaServer+"! Message: "+e.getLocalizedMessage());
			return false;
		} catch (IOException e) {
			System.err.println("sendMessage: Couldn't get I/O for the connection to the SisIYA server "+sisiyaServer+" ! Message: "+e.getLocalizedMessage());
			return false;
		}
		out.println(msg_str);
		out.close();
		
		return true;
	}	

	private boolean sendMessagesFromFile(String fileName)
	{
		PrintWriter out=null;

		try {
			out=new PrintWriter(sisiyaSocket.getOutputStream(),true);
		}
		catch(UnknownHostException e) {
			System.err.println("sendMessagesFromFile: Don't know about SisIYA server "+sisiyaServer+"! Message: "+e.getLocalizedMessage());
			return false;
		} catch (IOException e) {
			System.err.println("sendMessagesFromFile: Couldn't get I/O for " + "the connection to the SisIYA server "+sisiyaServer+"! Message: "+e.getLocalizedMessage());
			return false;
		}

		BufferedReader bfrFile=null;
		try {
			bfrFile=new BufferedReader(new FileReader(fileName));
		}
		catch(FileNotFoundException e) {
			return false;
		}

		String msg_str;
		while(true) {
			try {
				msg_str=bfrFile.readLine();
			}
			catch(IOException e) {
				System.err.println("sendMessagesFromFile: Could not read from file "+fileName+"!");
				break;
			}
			if(msg_str == null)
				break;
			System.out.println("line=["+msg_str+"]");
			System.out.println("line length="+msg_str.length());
			out.println(msg_str);
		}

		try {
			bfrFile.close();
		}
		catch(IOException e) {
			System.err.println("sendMessagesFromFile: Error closing file "+fileName+" Message:"+e.getLocalizedMessage());
			return false;
		}
		
		out.close();

		return true;
	}

	public void sendAll()
	{
		if(this.isFile(messageArgument))
			sendMessagesFromFile(messageArgument);
		else
			sendMessage(messageArgument);

		if(sisiyaSocket.isConnected()) {
			try {
				sisiyaSocket.close();
			}
			catch(IOException e) {
				System.err.println("sendAll: Error closing the connection to the SisIYA server! Message:"+e.getLocalizedMessage());
				System.exit(1);
			}
		}	
	}

	/*
	 * Prints usage info.
	*/
	public static void printUsage()
	{
		System.err.println("Usage         : "+progName+" server port message");
		System.err.println("Usage         : "+progName+" server port messages_file");
		System.err.println("server        : SisIYA server name or IP.");
		System.err.println("port          : SisIYA server port.");
		System.err.println("message       : The formated SisIYA message, without the new line character at the end.");
		System.err.println("messages_file : A file which contains SisIYA formated message on each line. In this case all");
		System.err.println("                messages are transferred through a single connection to the SisIYA server.");
		System.err.println("Example       : sisiya.example.org 8888 ~0~0~server1~20091026125100~10~Hello world!");
		System.err.println("SisIYA message format: [SP][serviceid][SP][statusid][SP][hostname][SP][YYYYMMTTHHMMSS][SP][expire][SP]message");
		System.err.println("[SP] is the field seperator. It must be one character.");
	}

	public static void main(String args[])
	{
		if(args.length != 3) {
			printUsage();
			System.exit(1);
		}
		SisIYASendMessage s=new SisIYASendMessage(args[0],Integer.valueOf(args[1]),args[2]);
		s.sendAll();
	}		       
}
