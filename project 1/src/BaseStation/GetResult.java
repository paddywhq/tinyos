/*                                  tab:4
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose, without fee, and without written
 * agreement is hereby granted, provided that the above copyright
 * notice, the following two paragraphs and the author appear in all
 * copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY
 * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
 * DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * Copyright (c) 2002-2005 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
/* Authors: Phil Levis <pal@cs.berkeley.edu>
 * Date:        December 1 2005
 * Desc:        Generic Message reader
 *               
 */

/**
 * @author Phil Levis <pal@cs.berkeley.edu>
 */


// package net.tinyos.tools;

import java.util.*;
import java.io.*;
import java.text.DecimalFormat;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class GetResult implements net.tinyos.message.MessageListener {

  private final int nodeNumber = 2;

  private MoteIF moteIF;
  int frequency = 100;
  public int[][] receive = new int[1001][nodeNumber + 1];
  
  public GetResult(MoteIF mif) {
    this.moteIF = mif;
    this.moteIF.registerListener(new GetMsg(), this);
  }

  public void start() {
    FrequencyControlMsg payload = new FrequencyControlMsg();
    try {
      // set new frequency
      while (true) {
        System.out.println("You can input the new frequency(ms): ");
        BufferedReader strin=new BufferedReader(new InputStreamReader(System.in));
        int temp = Integer.parseInt(strin.readLine());
        if (temp > 0) {
          // int storecomplete = 1;
          // for (int i = 1; i <= 1000; i++) {
            // int flag = 1;
            // for (int j = 1; j <= nodeNumber; j++)
              // flag *= receive[i][j];
            // if (flag == 0)
              // storecomplete = 0;
          // }
          // if (storecomplete == 0) {
            // File file = new File("result_"+frequency+"ms.txt");
            // if (file.exists())
              // file.delete();
            // file.createNewFile();
          // }

          for (int i = 1; i <= 1000; i++)
            for (int j = 1; j <= nodeNumber; j++)
              receive[i][j] = 0;
          frequency = temp;

          File file = new File("result_"+frequency+"ms.txt");
          if (file.exists())
            file.delete();
          file.createNewFile();

          payload.set_frequency(temp);
          payload.set_nodeid(0);
          moteIF.send(0, payload);
          System.out.println("Successfully set the frequency to " + frequency + "ms!");
          try {Thread.sleep(1000);} catch (InterruptedException exception) {}
        }
      }
    } catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }
  }
  
  public void messageReceived(int to, Message message) {
    GetMsg msg = (GetMsg)message;
    String filename = "result_"+frequency+"ms.txt";
    // write message to file
    if (msg.get_nodeid() > 0 && msg.get_nodeid() <= nodeNumber)
      if (receive[msg.get_sequence()][msg.get_nodeid()] == 0) {
        try {
          FileWriter filewriter = new FileWriter(filename, true);
          double temperature = -39.6 + 0.01 * (double)((msg.get_temperature() << 2) >> 2);
          double humidity = (double)((msg.get_humidity() << 4) >> 4);
          humidity = -2.0468 + 0.0367 * humidity - 1.5955 * 0.000001 * (double)Math.pow(humidity, 2);
          double light = 0.085 * (double)(msg.get_light());
          String item = msg.get_nodeid() + " " + new DecimalFormat("0000").format(msg.get_sequence()) + " "
                        + new DecimalFormat("0.00").format(temperature) + " " + new DecimalFormat("0.00").format(humidity) + " "
                        + new DecimalFormat("0.00").format(light) + " " + msg.get_time() + "\n";
          filewriter.write(item);
          filewriter.close();
          // System.out.println(item);
          receive[msg.get_sequence()][msg.get_nodeid()] = 1;
        } catch (IOException e) {
          e.printStackTrace();
        }
      }

    // System.out.println(+" ")
    // long t = System.currentTimeMillis();
    //    Date d = new Date(t);
    // System.out.print("" + t + ": ");
    // System.out.println(message);
  }

  private void addMsgType(Message msg) {
    moteIF.registerListener(msg, this);
  }

  public static void main(String[] args) throws Exception {
    String source = null;
    Vector v = new Vector();
    if (args.length > 0) {
      for (int i = 0; i < args.length; i++) {
        if (args[i].equals("-comm")) {
          source = args[++i];
        }
        else {
          String className = args[i];
          try {
            Class c = Class.forName(className);
            Object packet = c.newInstance();
            Message msg = (Message)packet;
            if (msg.amType() < 0) {
                System.err.println(className + " does not have an AM type - ignored");
            }
            else {
                v.addElement(msg);
            }
          }
          catch (Exception e) {
            System.err.println(e);
          }
        }
      }
    }
    else if (args.length != 0) {
      System.err.println("usage: GetResult [-comm <source>] message-class [message-class ...]");
      System.exit(1);
    }

    PhoenixSource phoenix;
    
    if (source != null) {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }

    File file = new File("result_100ms.txt");
    if (file.exists())
      file.delete();
    file.createNewFile();
    
    MoteIF mif = new MoteIF(phoenix);
    GetResult mr = new GetResult(mif);
    Enumeration msgs = v.elements();
    while (msgs.hasMoreElements()) {
      Message m = (Message)msgs.nextElement();
      mr.addMsgType(m);
      // moteIF.registerListener(m, mr);
    }
    mr.start();
  }
  
}