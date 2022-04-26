public with sharing class MailService {

    public static void sendEmail() {
        String subject = System.Label.EmailSubject;
        String body = System.Label.EmailBody;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setToAddresses(new String[]{
                UserInfo.getUserEmail()
        });
        email.setPlainTextBody(body);
        Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                email
        });
    }
}