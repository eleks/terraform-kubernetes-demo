//import groovy.lang.Closure;
import org.camunda.bpm.engine.delegate.DelegateExecution;
//import org.camunda.bpm.model.bpmn.instance.FlowElement;
//import org.camunda.bpm.model.bpmn.instance.Documentation;
import groovy.sql.Sql;
import java.util.regex.Pattern;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.io.IOException;
import java.sql.SQLException;
import java.io.StringReader;
import java.io.BufferedReader;

public class SQL {
	private static Pattern slashDelim = Pattern.compile("(?i)^/\\s*$");
	private static Pattern spaces = Pattern.compile("(?i)^\\s*$");

	public static Sql newInstance(String key)throws SQLException, ClassNotFoundException{
		return Sql.newInstance( CONFIG.getMap("database."+key) );
	}

	public static void execute(String key, String batch) throws Throwable{
		execute(key, batch, CAMUNDA.variables());
	}

	public static void execute(String key, String batch, Map params) throws Throwable{
		if(spaces.matcher(batch).matches())throw new RuntimeException("Nothing to execute. Define sql in `Documentation` section");
		Sql sql = newInstance(key);
		try{
			for(String cmd : splitCommands( batch, slashDelim)){
				sql.execute(params, cmd);
			}
		} catch(Throwable t) {
			try {
				if(!sql.getConnection().getAutoCommit())sql.rollback();
			}catch(SQLException e){}
			throw t; 
		} finally {
			try {
				sql.close();
			}catch(Throwable e){}
		}
	}

	public static List<String> splitCommands(String batch, Pattern delim) throws IOException {
		BufferedReader r = new BufferedReader(new StringReader(batch));
		List<String> cmds = new ArrayList();
		StringBuilder cmd = new StringBuilder();
		String line;
		while( (line = r.readLine())!=null ){
			if( delim.matcher(line).matches() ){
				//got a delimiter
				cmds.add(cmd.toString());
				cmd.setLength(0);
			} else {
				if(cmd.length()>0)cmd.append("\r\n");
				cmd.append(line);
			}
		}
		if( !spaces.matcher(cmd).matches() )cmds.add(cmd.toString());
		return cmds;
	}
}

