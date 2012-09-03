flash = (message, cl) ->
    flash_msg = humane.create
    humane.log( message, { timeout: 5000, clickToClose: true, addnCls: cl })

$(document).ready ->
    $('html').removeClass('no_js')
    $('.fancy-link').fancybox
        fitToView         : true
        autoSize          : true
        closeClick        : false
        showCloseButton   : false
        transitionIn      : 'fade'
        transitionOut     : 'fade'
        margin            : 5
        padding           : 5

    $('.delete').click ->
        answer = confirm("Are you sure you want to delete the selected object?")

    if $('#flash-msg').length > 0
        text = $('#flash-msg').text()
        cls  = $('#flash-msg').attr 'class'
        $('#flash-msg').remove()
        flash text, cls

