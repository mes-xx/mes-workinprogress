function sendViaGmail( recipient, message )

% This code was taken from
% http://www.mathworks.com/support/solutions/data/1-3PRRDV.html

% Define these variables appropriately:
mail = 'mes.mailer@gmail.com'; %Your GMail email address
password = 'thisisaGR8password'; %Your GMail password

% Then this code will set up the preferences properly:
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% Send the email
sendmail(recipient,message)