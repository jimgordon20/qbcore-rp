document.addEventListener("DOMContentLoaded", function () {
    let meterStarted = false;

    const updateMeter = (meterData) => {
        $("#total-price").html("$ " + meterData.currentFare.toFixed(2));
        $("#total-distance").html(meterData.distanceTraveled.toFixed(2) + " mi");
    };

    const resetMeter = () => {
        $("#total-price").html("$ 0.00");
        $("#total-distance").html("0.00 mi");
    };

    const toggleMeter = (enabled) => {
        if (enabled) {
            $(".toggle-meter-btn").html("<p>Started</p>");
            $(".toggle-meter-btn p").css({ color: "rgb(51, 160, 37)" });
        } else {
            $(".toggle-meter-btn").html("<p>Stopped</p>");
            $(".toggle-meter-btn p").css({ color: "rgb(231, 30, 37)" });
        }
    };

    const meterToggle = () => {
        if (!meterStarted) {
            hEvent("enableMeter", true);
            toggleMeter(true);
            meterStarted = true;
        } else {
            hEvent("enableMeter", false);
            toggleMeter(false);
            meterStarted = false;
        }
    };

    const openMeter = (meterData) => {
        $(".container").fadeIn(150);
        $("#total-price-per-100m").html("$ " + meterData.defaultPrice.toFixed(2));
    };

    const closeMeter = () => {
        $(".container").fadeOut(150);
    };

    window.addEventListener("message", function (event) {
        const eventData = event.data;
        const eventArgs = event.data.args[0];
        switch (eventData.name) {
            case "openMeter":
                if (eventArgs.toggle) {
                    openMeter(eventArgs.meterData);
                } else {
                    closeMeter();
                }
                break;
            case "toggleMeter":
                meterToggle();
                break;
            case "updateMeter":
                updateMeter(eventArgs.meterData);
                break;
            case "resetMeter":
                resetMeter();
                break;
            default:
                break;
        }
    });
});
