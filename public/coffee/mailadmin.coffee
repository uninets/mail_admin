$(document).ready ->
    $('.fancy-link').fancybox
        fitToView   : true
        autoSize    : true
        closeClick  : false
        openEffect  : 'none'
        closeEffect : 'none'

    $('.delete').click ->
        answer = confirm("Are you sure you want to delete the selected object?")

