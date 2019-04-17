that's just a script that removes `camunda-invoice` demo
<%
def webapps = context.file.getParentFile()
new File(webapps, "camunda-invoice").deleteDir()

%>