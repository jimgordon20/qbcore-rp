const slideUp = function () {
    document.querySelector(".container").style.display = "block";
    document.querySelector(".radio-container").style.transition = "bottom 250ms";
    document.querySelector(".radio-container").style.bottom = "6vh";
};

const slideDown = function () {
    document.querySelector(".radio-container").style.transition = "bottom 400ms";
    document.querySelector(".radio-container").style.bottom = "-110vh";
    setTimeout(function () {
        document.querySelector(".container").style.display = "none";
    }, 400);
};

const handleClick = function (e) {
    e.preventDefault();
    const channel = document.querySelector("#channel").value;
    if (e.target && e.target.id === "submit") {
        Events.Call("JOIN_RADIO", channel);
    } else if (e.target && e.target.id === "disconnect") {
        Events.Call("LEAVE_RADIO");
    } else if (e.target && e.target.id === "volumeUp") {
        Events.Call("VOLUME_UP");
    } else if (e.target && e.target.id === "volumeDown") {
        Events.Call("VOLUME_DOWN");
    } else if (e.target && e.target.id === "decreaseradiochannel") {
        Events.Call("DECREASE_RADIO_CHANNEL");
    } else if (e.target && e.target.id === "increaseradiochannel") {
        Events.Call("INCREASE_RADIO_CHANNEL");
    } else if (e.target && e.target.id === "poweredOff") {
        Events.Call("POWERED_OFF");
    }
};

Events.Subscribe("OPEN_RADIO", () => {
    slideUp();
    document.addEventListener("click", handleClick);
});

Events.Subscribe("CLOSE_RADIO", () => {
    slideDown();
    document.removeEventListener("click", handleClick);
});
