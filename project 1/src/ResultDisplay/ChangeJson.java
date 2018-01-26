import java.util.*;
import java.io.*;
import java.text.DecimalFormat;

public class ChangeJson{ 
  public static void main(String argv[]){
    String filePath = "result.txt";
    String jsonPath = "result.json";
    try
    {
      String encoding="GBK";
      File file = new File(filePath);
      File json = new File(jsonPath);
      if (!json.exists()){ 
        json.createNewFile(); 
      }
      if(file.isFile() && file.exists())
      {
        InputStreamReader read = new InputStreamReader(new FileInputStream(file),encoding);
        FileWriter writer = new FileWriter("result.json");
        BufferedReader bufferedReader = new BufferedReader(read);
        String lineTxt = null;
        String lineJson = null;
        String arrays[] = null;
        if((lineTxt = bufferedReader.readLine()) != null)
        {
          writer.write("{\n");
          writer.write("\"result\":[\n");
          arrays = lineTxt.split(" ");
          lineJson = "{\"nodeid\": \"" + arrays[0] + "\", \"sequence\": \"" + arrays[1] + "\", \"temperature\": \"" + arrays[2]
                     + "\", \"humidity\": \"" + arrays[3] + "\", \"light\": \"" + arrays[4] + "\", \"time\": \"" + arrays[5] + "\"}";
          writer.write(lineJson);
          while((lineTxt = bufferedReader.readLine()) != null)
          {
            writer.write(",\n");
            arrays = lineTxt.split(" ");
            lineJson = "{\"nodeid\": \"" + arrays[0] + "\", \"sequence\": \"" + arrays[1] + "\", \"temperature\": \"" + arrays[2]
                       + "\", \"humidity\": \"" + arrays[3] + "\", \"light\": \"" + arrays[4] + "\", \"time\": \"" + arrays[5] + "\"}";
            writer.write(lineJson);
          }
          writer.write("\n]\n}");
          writer.close();
          read.close();
        }
      }
      else{
        System.out.println("找不到指定的文件");
      }
    }
    catch (Exception e) {
      System.out.println("读取文件内容出错");
      e.printStackTrace();
    }
  }
}