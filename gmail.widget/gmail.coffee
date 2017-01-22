# Name: Gmail Widget for Ubersichts using oauth2
# Description: Shows the sender and the subject line of the latest email delivered to your Gmail inbox.
# Author: Ryuei Sasaki
# Github: https://github.com/louixs/

# Dependencies. Best to leave them alone.
_ = require('./assets/lib/underscore.js');

GOOGLE_APP:"gmail"

#==== Google API Credentials ====
# Fill in your Google API client id and client secret
# Save this file and a browser should launch asking you to allow widget to access gmail
# Once you allow, you will be presented with your Authorization code. Please fill it in and save the file.
# Your latest email should now show. If not try refreshing Übersicht.
# If you don't have your client id and/or client secret, please follow the steps in the Setup section in README.md.
 
CLIENT_ID:""
CLIENT_SECRET:""
AUTHORIZATION_CODE:""

command: """
  if [ ! -d assets ]; then
    cd "$PWD"/gmail.widget
    "$PWD"/assets/run.sh
  else
    assets/run.sh
  fi
"""

refreshFrequency: '5m' #5 minutes
#Other permitted formats: '2 days', '1d', '10h', '2.5 hrs', '2h', '1m', or '5s'

# render gets called after the shell command has executed. The command's output
# is passed in as a string. Whatever it returns will get rendered as HTML.
render: (output) -> """
  <div class="container">
    <div class="title">----Latest Gmail----</div>
    <div id="from"></div>
    <div id="subj"></div>
  </div>
"""

update: (output,domEl)->
  # @run """
  # if [ ! -e getTasks.sh ]; then
  #   "$PWD/tasks.widget/getTasks.sh"
  # else
  #   "$PWD/getTasks.sh"
  # fi
  # """, (err, output)->
  #console.log(output)

  addGmailToDom=()->
    data=output.split(",")
    from=data[0]
    subj=data[1]
  
    $(domEl).find("#from").text("From: "+from)
    $(domEl).find("#subj").text("Subj:"+subj)
    #console.log("item#{i+1}") for i in [0..2]

  makeDomClassP=(text)->
     "<div class=p>#{text}</p>"

  addErrMsgToDom=(text)->
     elemToAdd=makeDomClassP(text)      
     $(domEl).find(".container").html(elemToAdd)      

  showGmailIfErrorFree=->
     if parseInt(output) is 1
       errMsg="Please fill in your Client ID and Client secret the .coffee file, located on top of the file, in the .widget directory. Once you save and have a valid set of cliet ID/secret, a browser should launch and ask whether you want to allow your app to access Gmail. Please allow and you will be presented with Authorization code. If you don't have Client ID/secret, you would need to generate them on your google developer console. http://console.developers.google.com"
       addErrMsgToDom(errMsg)
     else if parseInt(output) is 2
       errMsg="A browser window launches asking if you would like to allow your app. Click Allow and your authorization code will be shown. Please copy the code and paste it in .coffee file. Once it is done please save this file to let Übersicht reload or/and use Refresh All Widgets again to reload."
       addErrMsgToDom(errMsg)
     else
       addGmailToDom()
   #--

  showGmailIfErrorFree()

    
# the CSS style for this widget, written using Stylus
# (http://learnboost.github.io/stylus/)
style: """
  //-webkit-backdrop-filter: blur(20px)
  @font-face
    font-family: 'hack'
    src: url('assets/lib/hack.ttf')
  font-family: hack, Andale Mono, Melno, Monaco, Courier, Helvetica Neue, Osaka
  color: #df740c  //#7eFFFF
  font-weight: 100
  font-size: 11 px
  top: 50%
  left: 2%
  line-height: 1.5
  //margin-left: -40px
  //padding: 120px 20px 20px
  
  .title
  //  text-align: center
    color: #ffe64d //#6fc3df 
    text-shadow: 0 0 1px rgba(#000, 0.5)  
"""
