library(RDCOMClient)
OutApp <- COMCreate("Outlook.Application")
outlookNameSpace <- OutApp$GetNameSpace("MAPI")



outMail = OutApp$CreateItem(0)
# outMail[["SendUsingAccount"]] = acc[[2]]$GetRootFolder()
# outMail[["SendUsingAccount"]] = acc[[2]]

# Signature <- outMail[["HTMLbody"]]
body <- "Was wollen wir denn in die Mail reinschreiben? :)."
outMail[["To"]] = "andreastonio.liebrand@union-investment.de"
outMail[["subject"]] = "TEST EMAIL"
outMail[["body"]] = "teil"

# outMail[["Attachments"]]$Add("C:\\Users\\Some\\Desktop\\file.csv")
outMail[["SendUsingAccount"]] = "vrpotentialnavigator@outlook.com"
outMail$Send()



