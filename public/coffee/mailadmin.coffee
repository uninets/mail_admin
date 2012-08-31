
class MailAdmin
    settings:
        keep_alive: true
        ws_url: 'ws://localhost:3000/chat'

    flash: (message, cl) ->
        flash_msg = humane.create
        humane.log message, { timeout: 5000, clickToClose: true, addnCls: cl }

    chat: (keep_alive) ->
        $('#msg').focus()

        $('#msg').keydown (e) ->
            if e.keyCode == 13
                socket.send $('#msg').val()
                $('#msg').val('')

        log = (message) ->
            $('#log').val( $('#log').val() + message + "\n" )

        socket = new WebSocket this.settings.ws_url

        socket.onopen = () ->
            log 'Connection opened'
            socket.send 'connected'

        socket.onmessage = (msg) ->
            console.log msg.stringify
            res = JSON.parse msg.data
            log '[' + res.hms + '] ' + res.name + ': ' + res.text

        keep_alive_fun = () ->
            socket.send 'q77bY7ufAi9e'
            if keep_alive
                setTimeout keep_alive_fun, 5000

        setTimeout keep_alive_fun, 1000


$(document).ready ->

    mailAdmin = new MailAdmin

    $('html').removeClass 'no_js'
    $('.fancy-link').fancybox
        fitToView   : true
        autoSize    : true
        closeClick  : false
        openEffect  : 'none'
        closeEffect : 'none'

    $('.delete').click ->
        answer = confirm "Are you sure you want to delete the selected object?"

    if $('#chat_window').length > 0
        mailAdmin.chat true

    if $('#flash-msg').length > 0
        text = $('#flash-msg').text()
        cls  = $('#flash-msg').attr 'class'
        $('#flash-msg').remove()
        mailAdmin.flash text, cls

