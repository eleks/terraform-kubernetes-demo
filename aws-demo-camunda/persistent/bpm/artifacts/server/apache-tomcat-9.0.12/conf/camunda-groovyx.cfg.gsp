import groovyx.acme.net.AcmeHTTP;

//sensitive = dependency.load('sensitive.cfg')

email {
	//for gmail smtp check your mailbox if google not blocking you...
	mail.transport.protocol = "smtp"
	mail.smtp.host          = "<%= camunda.mail.host %>"
	mail.smtp.port          = "<%= camunda.mail.port %>"
	//mail.smtp.socketFactory.port = "465"
    //mail.smtp.socketFactory.class = "javax.net.ssl.SSLSocketFactory"
	//mail.smtp.ssl.enable    = "true"
	mail.smtp.starttls.enable= "<%= camunda.mail.tls %>"
	//=======  custom fields processed by class EMAIL =======
	mail.user               = "<%= camunda.mail.user %>"
	mail.pass               = "<%= camunda.mail.pass %>"
	mail.from               = "<%= camunda.mail.user %>"
	mail.fromName           = "camunda demo"
}


database {
	demo {
		//all db parameters defined during templating because they are coming from terraform
		driver   = "<%= camunda.db.demo.driver %>"
		url      = "<%= camunda.db.demo.url    %>"
		user     = "<%= camunda.db.demo.user   %>"
		password = "<%= camunda.db.demo.pass   %>"
	}
}

rest {
    //define jira requests
    jira {
        http_client = AcmeHTTP.builder(
            url: "<%= camunda.rest.jira.url %>/rest/api/2",
            headers: [
                Authorization   : "<%= camunda.rest.jira.auth %>",
                "Content-Type"  : "application/json"
            ]
        )
        //returns url to browse jira issue for user
        browse = {_key->  "<%= camunda.rest.jira.url %>/${_key}" }
        //method to register issue in jira
        tripRegister = { _summary, _description ->
            def t = rest.jira.http_client.post{
                setPath ("/issue")
                body = [
                    fields: [
                        project:   [ id: "<%= camunda.rest.jira.trip.projectId %>" ],
                        issuetype: [ id: "<%= camunda.rest.jira.trip.issueType %>" ],
                        summary: _summary,
                        description: _description,
                    ],
                ]
            }
            assert t.response.code in [200,201]
            return t.response.body
        }
        //method add a comment into an jira issue 
        comment = { _key, _body ->
            def t = rest.jira.http_client.post{
                setPath ("/issue/${_key}/comment")
                setBody ( [ "body": _body ] )
            }
            assert t.response.code in [200,201]
            return t.response.body
        }
        //moves issue to a defined status
        toStatus = { _key, _status ->
        	//get current status
            def t = rest.jira.http_client.get{
                setPath ("/issue/${_key}")
            }
            assert t.response.code in [200,201]
        	if( _status.equalsIgnoreCase(t.response.body.fields.status.name) ) return true
        	//get available paths
            t = rest.jira.http_client.get{
                setPath ("/issue/${_key}/optimisticTransitions")
            }
            //println t.response
            assert t.response.code in [200,201]
            def trn = t.response.body.transitions.find{ _status.equalsIgnoreCase(it.to.name) }
            assert trn: "transition for $_status not found "
            t = rest.jira.http_client.post{
                setPath ("/issue/${_key}/transitions")
                setBody ( [ "transition": [id:trn.id] ] )
                setReceiver(AcmeHTTP.TEXT_RECEIVER)
            }
            assert t.response.code in [200,201,204]
            return true
        }
    }
}
