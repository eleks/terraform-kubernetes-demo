following script creates `.h2.server.properties` file at user home
<%

def p = new Properties()
p."0" = "camunda|${camunda.db.main.driver}|${camunda.db.main.url}|${camunda.db.main.user}"
p."1" = "camunda|${camunda.db.demo.driver}|${camunda.db.demo.url}|${camunda.db.demo.user}"
new File(System.getProperty("user.home")+"/.h2.server.properties").withOutputStream{ p.store(it, "H2 Server Properties") }

%>