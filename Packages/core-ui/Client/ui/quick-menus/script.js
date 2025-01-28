// Input menu events
$('.input-menu .confirm').on('click', function () {
    const value = $('.input-menu input').val();
    Events.Call('InputValueConfirmed', value);
});

$('.input-menu .cancel').on('click', function () {
    Events.Call('InputValueCanceled');
});

$('.input-menu .close-panel').on('click', function () {
    Events.Call('InputValueCanceled');
});

// Confirm menu events
$('.confirm-menu .confirm').on('click', function () {
    Events.Call('ConfirmConfirmed');
});

$('.confirm-menu .cancel').on('click', function () {
    Events.Call('ConfirmCanceled');
});

$('.confirm-menu .close-panel').on('click', function () {
    Events.Call('ConfirmCanceled');
});

// Listening to events from Lua
Events.Subscribe("ShowInputMenu", function (title, placeholder) {
    $('.input-menu .header .title').text(title);
    $('.input-menu input').attr('placeholder', placeholder);
    $('body').addClass('in-input-menu');
});

Events.Subscribe("HideInputMenu", function () {
    $('.input-menu input').val('');
    $('body').removeClass('in-input-menu');
});

Events.Subscribe("ShowConfirmMenu", function (title, message) {
    $('.confirm-menu .header .title').text(title);
    $('.confirm-menu .message').text(message);
    $('body').addClass('in-confirm-menu');
});

Events.Subscribe("HideConfirmMenu", function () {
    $('body').removeClass('in-confirm-menu');
});