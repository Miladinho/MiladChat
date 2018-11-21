// Example from https://medium.com/@martin.sikora/node-js-websocket-simple-chat-tutorial-2def3a841b61

$(function() {
  "use strict";
  // for better performance - to avoid searching in DOM
  let content = $('#content');
  let input = $('#input');
  let status = $('#status');
  let myColor = 'blue';
  // my name sent to the server
  var myName = false;
  var user = false;

  let setErrorMessage =  function() {
    content.html($('<p>', {
      text: 'Sorry, but there\'s some problem with your '
         + 'connection or the server is down.'
    }));
  }
  // if user is running mozilla then use it's built-in WebSocket
  window.WebSocket = window.WebSocket || window.MozWebSocket;
  // if browser doesn't support WebSocket, just show
  // some notification and exit
  if (!window.WebSocket) {
    content.html($('<p>',
      { text:'Sorry, but your browser doesn\'t support WebSocket.'}
    ));
    input.hide();
    $('span').hide();
    return;
  }


  // open connection
  Parse.initialize("myAppId");
  Parse.serverURL = 'http://127.0.0.1:1337/parse';
  Parse.User.logOut(); // session clearing

  if (performance.navigation.type == 1) {
    console.info( "This page is reloaded" );
    Parse.User.logOut();
  } 

  let c = new Parse.Query('Chat')
  var connection = c.subscribe()
  connection.on('open', () => { 
    input.removeAttr('disabled');
    status.text('Choose name:');
  });

  connection.on('error', (error) => {
    console.log(error)
    setErrorMessage()
  });

  connection.on('create', async (chat) => {
    input.removeAttr('disabled').focus();

    var color = myColor
 
    if (Parse.User.current().id !== chat.attributes.User.id) {
      color = "red"
      const otherUserQuery = new Parse.Query(Parse.User)
      otherUserQuery.get(chat.attributes.User.id)
      var otherUser = await otherUserQuery.find()
    }
    addMessage(chat.attributes.User.attributes.username, chat.attributes.message,
               color, new Date(chat.attributes.createdAt));
  });
  /**
   * Send message when user presses Enter key
   */

  var handleSubmit = async function(e) {
    if (e.keyCode === 13) {
      var msg = $(this).val();
      if (!msg) {
        return;
      }

      input.attr('disabled', 'disabled');
      // we know that the first message sent from a user their name
      if (myName === false) {
        user = new Parse.User();
        user.set('username', msg);
        user.set('password', 'testest')
        try {
          await user.signUp();
          myName = msg
          status.text(myName + ': ').css('color', myColor);
          $(this).val('');
        } catch (error) {
          alert("Error: " + error.code + " " + error.message);
        }
        input.removeAttr('disabled');
      } else {
        // send the message as an ordinary text
        const ChatMessage = Parse.Object.extend('Chat')
        let newChat = new ChatMessage()
        newChat.set('message', msg)
        newChat.set('User', user)
        try {
          await newChat.save()
        } catch (error) {
          console.log('error sending message')
          console.log(error)
        }
        input.removeAttr('disabled');
        $(this).val('');
      }
    }
  }
  input.keydown(handleSubmit);

  connection.on('close', () => {
    alert('subscription closed');
  });


  /**
   * Add message to the chat window
   */
  function addMessage(author, message, color, dt) {
    content.prepend('<p><span style="color:' + color + '">'
        + author + '</span> @ ' + (dt.getHours() < 10 ? '0'
        + dt.getHours() : dt.getHours()) + ':'
        + (dt.getMinutes() < 10
          ? '0' + dt.getMinutes() : dt.getMinutes())
        + ': ' + message + '</p>');
  }
});