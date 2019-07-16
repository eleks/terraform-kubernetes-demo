/**
 * config helper
 */
import groovy.util.ConfigSlurper;
import groovy.util.ConfigObject;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.LinkedHashSet;
import java.util.Stack;
import java.io.File;
import java.util.Timer;
import java.util.TimerTask;
import org.codehaus.groovy.runtime.MethodClosure;

public class CONFIG {
	//private static File cfgFile = null;
	private static ConfigObject internal$cfg = null;
	private static volatile Dependency internal$dependency = new Dependency();

	private static Timer internal$timer = null;
	private static Object internal$syncKey = new Object();

	public static class Dependency{
		private long lastModified = 0;
		private ConfigSlurper slurper = new ConfigSlurper();
		private Set<File> list = new LinkedHashSet();
		private Stack<File> stack = new Stack();

		Dependency(){
			HashMap binding = new HashMap();
			binding.put("dependency", this);
			slurper.setBinding(binding);
			lastModified = lastModified();
		}
		
		ConfigObject load(File f)throws java.net.MalformedURLException{
			stack.push(f);
			list.add(f);
			ConfigObject o = slurper.parse(f.toURI().toURL());
			stack.pop();
			lastModified = lastModified();
			return o;
		}
		ConfigObject load(String relative)throws java.net.MalformedURLException{
			return load(new File(basedir(),relative));
		}
		private long lastModified(){
			long hash = -1234;
			for(File f : list){ 
				hash += f.lastModified();
			}
			return hash;
		}
		File basedir(){
			File f = stack.size()>0 ? stack.peek() : first();
			return f.getParentFile();
		}
		File first(){
			if( list.size()>0  )return list.iterator().next();
			if( stack.size()>0 )return stack.get(0);
			throw new IllegalStateException("CONFIG not initialised correctly");
		}
		boolean changed(){
			return lastModified!=lastModified();
		}
	}


	private static File lookupRootConfig(){
		LinkedHashSet<String> list = new LinkedHashSet();
		File f = new File("./conf/camunda-groovyx.cfg");
		if(f.exists())return f;
		list.add(f.toString());

		f = new File("../conf/camunda-groovyx.cfg");
		if(f.exists())return f;
		list.add(f.toString());

		f = new File(System.getProperty("catalina.home")+"/conf/camunda-groovyx.cfg");
		if(f.exists())return f;
		list.add("${System[catalina.home]}/conf/camunda-groovyx.cfg");

		f = new File(System.getenv("GROOVYX_CONFIG"));
		if(f.exists())return f;
		list.add("${env[GROOVYX_CONFIG]}");

		throw new RuntimeException("The file `camunda-groovyx.cfg` not found. Current path: `"+new File(".").getAbsolutePath()+"`\n Tried: "+list);
	}

	public static ConfigObject get(){
		if(internal$cfg==null){
			synchronized(internal$syncKey) {
				if(internal$cfg==null){
					try {
						internal$cfg = internal$dependency.load(lookupRootConfig());
						if(internal$timer==null){
							internal$timer = new Timer(CONFIG.class.getName(), true);
							internal$timer.schedule(new TimerTask(){
									public void run(){
										try{
											if(internal$dependency.changed()){
												Dependency newDependency = new Dependency();
												internal$cfg=newDependency.load(lookupRootConfig());
												internal$dependency = newDependency;
												System.err.println(CONFIG.class.getName()+".timer config reloaded");
											}
										}catch(Throwable t){
											System.err.println(CONFIG.class.getName()+".timer error: "+t);
										}
									}
								}, 7432, 7432);
						}
					}catch(java.net.MalformedURLException e){
						throw new RuntimeException(e.toString(),e);
					}
				}
			}	
		}
		return internal$cfg;
	}

	public static Object get(String keys){
		Object r = get();
		String [] keyArr = keys.split("\\.");
		for(int i=0;i<keyArr.length;i++){
			if(r instanceof ConfigObject){
				r = ((ConfigObject)r).get(keyArr[i]);
			}else throw new RuntimeException("Can't get property `"+keyArr[i]+"` on "+r+" ( "+(r==null?"":r.getClass())+" ). Expression="+keys);
		}
		return r;
	}
	public static Map<String,Object> getMap(String keys){
		Object v = get(keys);
		if( v instanceof ConfigObject )	return ((ConfigObject)get(keys)).flatten();
		if( v instanceof Map )	return (Map)get(keys);
		throw new RuntimeException("Can't get property `"+keys+"` expected ConfigObject or Map, got: "+v+" "+(v==null?"":v.getClass()));
	}
	public static String getString(String keys){
		return get(keys).toString();
	}
	public static Number getNumber(String keys){
		return (Number) get(keys);
	}

	/** this will be called by groovy when internal property not found */
    public static Object $static_propertyMissing(String key){
    	Object v = CONFIG.get("rest."+key);
    	if(v==null)throw new RuntimeException("Config key not found `rest."+key+"`");
        return v;
    }


}
