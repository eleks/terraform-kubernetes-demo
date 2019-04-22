/**
 * email helper
 */
import java.util.*; 
import javax.mail.*;
import javax.mail.internet.*;
import javax.mail.util.*;
import javax.activation.*;


public class EMAIL {

    /**
	* params:
	*	from:       "user@host.domain"
	*	fromName:   "Personal Name"
	*	to:         "user1@host.domain, user2@host.domain, ..."
	*	replyTo:    "user1@host.domain, user2@host.domain, ..."
	*	subject
	*	body
	*	bodyType    "html" or text by default
	*/
	public static void send(Map params){
        Properties props = CONFIG.getMap("email") as Properties
        //-----------------------------------------------------
		def defaultFrom     = props.remove("mail.from");
		def defaultFromName = props.remove("mail.fromName");
		def mailUser        = props.remove("mail.user");
		def mailPass        = props.remove("mail.pass");

		Session session = null
		if(mailUser && mailPass){
	        props.put("mail.smtp.auth", "true")
	        session = Session.getDefaultInstance(props,
                new javax.mail.Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(mailUser, mailPass);
                    }
                });
		}else{
			session = Session.getInstance(props);
		}

		Transport transport = session.getTransport();

		Map attachments = params["attachments"]
        //new Message
        MimeMessage message = new MimeMessage(session);
		if (params.containsKey("from")) {
			if(params.containsKey("fromName")) {
				message.setFrom( new InternetAddress(params["from"], params["fromName"]) );
			} else {
				message.setFrom( new InternetAddress(params["from"]));
			}
		} else {
			// default from value
			if(defaultFromName){
				message.setFrom( new InternetAddress(defaultFrom, defaultFromName) );
			}else{
				message.setFrom( new InternetAddress(defaultFrom) );
			}
		}
        message.setRecipients( MimeMessage.RecipientType.TO, parseAddress(params['to']) );
		if(params.containsKey("replyTo")){
			message.setReplyTo( parseAddress(params["replyTo"]) );
		}
        message.setSubject(params["subject"], "UTF-8");
        //message content
        MimeMultipart multipart = new MimeMultipart();
        //body part
        BodyPart messageBodyPart = new MimeBodyPart();
        if (params.containsKey("bodyType")){
            if (params["bodyType"] == 'html') {
                //messageBodyPart.setContent(params['body'], "text/html");
                messageBodyPart.setText(params['body'], "UTF-8", "html");
            } else {
                messageBodyPart.setText(params['body'], "UTF-8");
            }
        } else {
            messageBodyPart.setText(params['body'], "UTF-8");
        }
        multipart.addBodyPart(messageBodyPart);
        //attachments Part
        attachments?.each { fileName, file -> 
            if (fileName != null && !(fileName instanceof String)) {
                throw new IllegalArgumentException("Incorrect type of file name: " + fileName.getClass())
            }
            if (!fileName) {
                fileName = "attach.dat"
            }
            if (file == null) {
                return
            }
            if (!(file.getClass() in [byte[].class, String.class])) {
                throw new IllegalArgumentException("Incorrect type of file: " + file.getClass())
            }

            def attachment = new MimeBodyPart()
            attachment.setDataHandler(
                    new DataHandler(
                        new ByteArrayDataSource(file, getContentType(fileName))
                    ))
            attachment.setFileName(fileName)
            multipart.addBodyPart(attachment)
        }
        message.setContent(multipart);
        
        //sendEmail
       	transport.connect();
        transport.sendMessage(message, message.getAllRecipients());
        transport.close();
    }
	
	private static Address[] parseAddress(String addrString){
		java.util.ArrayList<Address> arr=new java.util.ArrayList<Address>();
		for( token in addrString.tokenize(',') ){
			arr.add( new InternetAddress( token.trim(), false ) );
		}
		return arr.toArray( new Address[arr.size()] );
	}
    
    private static String getContentType(String fileName) {
        switch (fileName.toLowerCase()) {
            case ~".*(pdf)"     : return "application/pdf"
            case ~".*(xml)"     : return "application/xml"
            case ~".*(txt)"     : return "text/plain"
            //case ~".*(html)"    : return "text/html"
        }
        return URLConnection.getFileNameMap().getContentTypeFor(fileName)
    }

}
