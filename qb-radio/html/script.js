document.addEventListener("DOMContentLoaded", function () {
    function SlideUp() {
        const container = document.querySelector(".container");
        const radioContainer = document.querySelector(".radio-container");

        container.style.display = "block";
        radioContainer.style.transition = "bottom 250ms";
        radioContainer.style.bottom = "6vh";
    }

    function SlideDown() {
        const container = document.querySelector(".container");
        const radioContainer = document.querySelector(".radio-container");

        radioContainer.style.transition = "bottom 400ms";
        radioContainer.style.bottom = "-110vh";

        setTimeout(function () {
            container.style.display = "none";
        }, 400);
    }

    document.getElementById("submit").addEventListener("click", function (e) {
        e.preventDefault();

        const channel = document.getElementById("channel").value;
        hEvent("joinRadio", { channel: channel }, (data) => {
            if (data.canaccess) {
                document.getElementById("channel").value = data.channel;
            }
        });
    });

    document.getElementById("disconnect").addEventListener("click", function (e) {
        e.preventDefault();

        hEvent("leaveRadio", {});
    });

    document.getElementById("volumeUp").addEventListener("click", function (e) {
        e.preventDefault();

        const channel = document.getElementById("channel").value;
        hEvent("volumeUp", { channel: channel });
    });

    document.getElementById("volumeDown").addEventListener("click", function (e) {
        e.preventDefault();

        const channel = document.getElementById("channel").value;
        hEvent("volumeDown", { channel: channel });
    });

    document.getElementById("decreaseradiochannel").addEventListener("click", function (e) {
        e.preventDefault();

        const channel = document.getElementById("channel").value;

        hEvent("decreaseradiochannel", { channel: channel }, (data) => {
            if (data.canaccess) {
                document.getElementById("channel").value = data.channel;
            }
        });
    });

    document.getElementById("increaseradiochannel").addEventListener("click", function (e) {
        e.preventDefault();

        const channel = document.getElementById("channel").value;
        hEvent("increaseradiochannel", { channel: channel }, (data) => {
            if (data.canaccess) {
                document.getElementById("channel").value = data.channel;
            }
        });
    });

    document.getElementById("poweredOff").addEventListener("click", function (e) {
        e.preventDefault();
        const channel = document.getElementById("channel").value;
        hEvent("poweredOff", { channel: channel });
    });

    window.addEventListener("message", function (event) {
        if (event.data.name == "open") {
            SlideUp();
        }

        if (event.data.name == "close") {
            SlideDown();
        }
    });

    // document.onkeyup = function (data) {
    //     if (data.key == "Escape") {
    //         // Escape key
    //         postData("https://qb-radio/escape", {});
    //     } else if (data.key == "Enter") {
    //         // Enter key
    //         const channel = document.getElementById("channel").value;
    //         postData("https://qb-radio/joinRadio", { channel: channel }).then((data) => {
    //             if (data.canaccess) {
    //                 document.getElementById("channel").value = data.channel;
    //             }
    //         });
    //     }
    // };
});
